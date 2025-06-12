import logging
from typing import Optional, List
import yaml
from pymongo import MongoClient
import numpy as np
from langchain.schema.output_parser import StrOutputParser
from langchain.schema.runnable import RunnablePassthrough
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from sentence_transformers import SentenceTransformer
from langchain_community.chat_message_histories import MongoDBChatMessageHistory
from langchain.memory import ConversationBufferMemory

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ChatBot:
    def __init__(self, config_path: str = "config.yaml"):
        """Initialize ChatBot with configuration."""

        with open(config_path, 'r') as file:
            config = yaml.safe_load(file)
        
        self.client = MongoClient(config['mongo_connection_str'])
        self.db = self.client[config['database_name']]
        self.collection = self.db[config['collection_name']]
        # Add collection for conversation memory
        self.memory_collection = self.db.get_collection('conversation_memory')
        
        self.embedding_model = SentenceTransformer(config['embedding_model'])
        
        self.model = ChatOpenAI(
            model_name=config['model_name'],
            openai_api_key=config['openai_api_key'],
            temperature=config['temperature']
        )

        # Updated prompt with explicit instructions to remember previous messages and handle references
        self.prompt = ChatPromptTemplate.from_template(
            """
            You are a helpful and friendly chatbot for Dar Al-Hekma University. Your role is to assist users by answering their questions clearly and concisely.
            
            IMPORTANT: You have access to the conversation history. ALWAYS refer to this history when the user asks about previous messages.
            If asked about previous messages, check the conversation history and respond with specific details about what was said.
            Never say you don't have the ability to remember previous messages, as you have full access to the conversation history.
            
            IMPORTANT FOR FOLLOW-UP QUESTIONS: When the user asks a short follow-up question or uses pronouns like "it", "this", "they", etc.,
            always resolve these references based on the previous conversation. For example, if they ask "Is it available?" after discussing 
            a program, understand that "it" refers to that program and respond accordingly.
            
            CRITICAL INSTRUCTION: NEVER start your response with phrases like "Based on our previous conversation", "From our earlier discussion",
            "According to what was mentioned before", or any similar meta-references. Always answer directly as if you inherently understand
            what the user is referring to. Give immediate, direct answers without explaining how you determined what they meant. Directly answer
            without refering what "it", "this", "they", etc., mean.
            
            Previous conversation:
            {history}
            
            Context:
            {context}
            
            User's current question:
            {question}
            
            Answer:
            """
        )
        
        self.mongo_connection_string = config['mongo_connection_str']
        self.db_name = config['database_name']

    def compute_cosine_similarity(self, vec1, vec2):
        """Compute cosine similarity between two vectors."""
        vec1 = np.array(vec1)
        vec2 = np.array(vec2)
        dot_product = np.dot(vec1, vec2)
        norm1 = np.linalg.norm(vec1)
        norm2 = np.linalg.norm(vec2)
        return dot_product / (norm1 * norm2)

    def get_relevant_chunks(self, query: str, k: int = 5, score_threshold: float = 0.2) -> List[str]:
        """Retrieve relevant chunks from MongoDB using vector similarity."""

        query_embedding = self.embedding_model.encode(query)
        
        all_docs = list(self.collection.find({}, {'content': 1, 'embedding': 1}))
        
        similarities = []
        for doc in all_docs:
            similarity = self.compute_cosine_similarity(query_embedding, doc['embedding'])
            if similarity >= score_threshold:
                similarities.append((doc['content'], similarity))
        
        similarities.sort(key=lambda x: x[1], reverse=True)
        return [content for content, _ in similarities[:k]]

    def chat(
        self,
        query: str,
        k: int = 5,
        score_threshold: float = 0.2,
        session_id: str = None
    ) -> str:
        """Chat with the bot using RAG."""
        logger.info(f"Processing query: {query}")
        
        if session_id is None:
            return "Error: No session ID provided. Please provide a session ID to use the chatbot."
        
        # Use LangChain's MongoDB Chat History
        message_history = MongoDBChatMessageHistory(
            connection_string=self.mongo_connection_string,
            session_id=session_id,
            database_name=self.db_name,
            collection_name="langchain_messages"
        )
        
        # Create a ConversationBufferMemory from the message history
        memory = ConversationBufferMemory(
            memory_key="history",
            chat_memory=message_history,
            return_messages=True  # Changed to True to get the actual message objects
        )
        
        # Get history
        history_data = memory.load_memory_variables({})
        history = history_data.get("history", "")
        
        # Enhanced query creation for short queries to improve context retention
        if len(query.split()) <= 3:  # For short queries (3 words or less)
            # Get recent messages from history to provide context
            recent_messages = []
            if message_history.messages:
                # Take up to last 4 messages (2 exchanges) for context
                recent_subset = message_history.messages[-4:] if len(message_history.messages) >= 4 else message_history.messages
                recent_messages = [msg.content for msg in recent_subset]
            
            # Combine recent message content with the current query
            if recent_messages:
                # Instead of just concatenating, make a more structured query
                ai_last_message = recent_messages[-1] if len(recent_messages) % 2 == 0 else recent_messages[-2]
                context_query = f"{ai_last_message} {query}"
                logger.info(f"Enhanced query for short input: {context_query}")
                retrieved_chunks = self.get_relevant_chunks(context_query, k, score_threshold)
            else:
                retrieved_chunks = self.get_relevant_chunks(query, k, score_threshold)
        else:
            # Regular retrieval for longer queries
            retrieved_chunks = self.get_relevant_chunks(query, k, score_threshold)
        
        if not retrieved_chunks:
            # Even with no chunks, we process the query using memory
            retrieved_chunks = ["No specific context found for this query."]
        
        formatted_input = {
            "history": history,
            "context": "\n\n".join(retrieved_chunks),
            "question": query,
        }

        try:
            # Generate the response using the model
            chain = (
                RunnablePassthrough()
                | self.prompt
                | self.model
                | StrOutputParser()
            )
            response = chain.invoke(formatted_input)
            
            # Save the user message and bot response to memory
            message_history.add_user_message(query)
            message_history.add_ai_message(response)
            
            logger.info(f"Response generated for session {session_id}")
            return response
            
        except Exception as e:
            logger.error(f"Error generating response: {str(e)}")
            return "I apologize, but I encountered an error while processing your request. Please try again."