from langchain_community.document_loaders import PyPDFLoader, Docx2txtLoader, UnstructuredHTMLLoader, UnstructuredPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_chroma import Chroma
from typing import List
from langchain_core.documents import Document
import os
import openai
import traceback

# Initialize OpenAI key
openai.api_key = "sk--iIesrgwskbU4s1HxtelBn1sRt3bUvi9Tv2Dpu02M0T3BlbkFJ7aal4rANaVqWXRSI72klvx4Q4Zg7DiLslKikzi_8wA"

# Chroma + embeddings setup
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200, length_function=len)
embedding_function = OpenAIEmbeddings()
vectorstore = Chroma(persist_directory="./chroma_db", embedding_function=embedding_function)

def load_and_split_document(file_path: str) -> List[Document]:
    try:
        print(f"🔍 Loading document: {file_path}")
        if file_path.endswith('.pdf'):
            try:
                loader = PyPDFLoader(file_path)
                documents = loader.load()
                if not documents:
                    print("⚠️ PyPDFLoader returned empty. Falling back to UnstructuredPDFLoader...")
                    loader = UnstructuredPDFLoader(file_path)
                    documents = loader.load()
            except Exception as e:
                print(f"⚠️ PyPDFLoader failed: {e}. Using UnstructuredPDFLoader...")
                loader = UnstructuredPDFLoader(file_path)
                documents = loader.load()

        elif file_path.endswith('.docx'):
            loader = Docx2txtLoader(file_path)
            documents = loader.load()

        elif file_path.endswith('.html'):
            loader = UnstructuredHTMLLoader(file_path)
            documents = loader.load()

        else:
            raise ValueError(f"Unsupported file type: {file_path}")
        
        if not documents:
            raise ValueError("🚫 No text found in document.")

        print(f"✅ Loaded {len(documents)} document(s). Splitting into chunks...")
        return text_splitter.split_documents(documents)
    
    except Exception as e:
        print(f"❌ Error loading/splitting document: {e}")
        traceback.print_exc()
        raise

def index_document_to_chroma(file_path: str, file_id: int) -> bool:
    try:
        splits = load_and_split_document(file_path)
        
        # Add metadata to each split
        for split in splits:
            split.metadata['file_id'] = file_id
        
        vectorstore.add_documents(splits)
        # vectorstore.persist()
        return True
    except Exception as e:
        print(f"❌ Error indexing document: {e}")
        traceback.print_exc()  # This will print the full traceback of the error
        return False

def delete_doc_from_chroma(file_id: int):
    try:
        docs = vectorstore.get(where={"file_id": file_id})
        print(f"🧾 Found {len(docs['ids'])} document chunks for file_id {file_id}")

        vectorstore._collection.delete(where={"file_id": file_id})
        print(f"🗑️ Deleted all documents with file_id {file_id}")

        return True

    except Exception as e:
        print(f"❌ Error deleting document with file_id {file_id} from Chroma: {str(e)}")
        traceback.print_exc()
        return False
