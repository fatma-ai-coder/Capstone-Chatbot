import faiss
import numpy as np
import openai
import pickle
from transformers import AutoTokenizer, AutoModel

import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"

# Set your OpenAI API key
openai.api_key = 'sk-aMrflV4Tv_76JR7iSbfC412BX6xUeIzWk3wfsoWwOvT3BlbkFJm9wCXTaAWqO_9d014jL4OBc8VgSQa3QQxktXNy0gcA'

# Initialize the tokenizer and model
model_name = "sentence-transformers/all-MiniLM-L6-v2"  # Use the same model as in pdf2vec.py
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModel.from_pretrained(model_name)

# Load the FAISS index
index = faiss.read_index("handbook_index.faiss")

# Load the text chunks
with open("handbook_chunks.pkl", "rb") as f:
    chunks = pickle.load(f)

# Function to chunk long text
def chunk_text(text, max_length=512):
    words = text.split()
    chunks = []
    current_chunk = []
    
    for word in words:
        # Check if adding this word exceeds the max_length
        if len(current_chunk) + len(word) + 1 > max_length:  # +1 for the space
            chunks.append(' '.join(current_chunk))
            current_chunk = [word]  # Start a new chunk with the current word
        else:
            current_chunk.append(word)
    
    # Add any remaining words as a final chunk
    if current_chunk:
        chunks.append(' '.join(current_chunk))
    
    return chunks

# Function to embed the query
def embed_query(query):
    inputs = tokenizer(query, return_tensors="pt", padding=True, truncation=True, max_length=512)
    outputs = model(**inputs)
    return outputs.last_hidden_state.mean(dim=1).detach().numpy()

# Function to find the nearest vector
def find_nearest_vector(query_vector):
    D, I = index.search(query_vector, k=1)  # Get the index of the nearest chunk
    return I[0][0]  # Return the index of the closest vector

# Function to ask ChatGPT
def ask_chatgpt(question, context):
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are an assistant that provides information based on provided context."},
            {"role": "user", "content": f"{context}\n\nUser question: {question}"}
        ]
    )
    return response['choices'][0]['message']['content']


# Main loop to interact with the user
def main():
    while True:
        user_question = input("Ask your question (type 'exit' to quit): ")
        if user_question.lower() == 'exit':
            break
        
        # Embed the user's question
        query_vector = embed_query(user_question)

        # Find the nearest vector index
        nearest_index = find_nearest_vector(query_vector)

        # Retrieve the corresponding chunk of text
        context = chunks[nearest_index]

        # Ask ChatGPT for an answer
        answer = ask_chatgpt(user_question, context)
        
        print("ChatGPT Response:", answer)

if __name__ == "__main__":
    main()
