import os
from typing import List, Dict
import logging
from pymongo import MongoClient
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import PyPDFLoader
from sentence_transformers import SentenceTransformer
import numpy as np
import yaml

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PDFProcessor:
    def __init__(self, mongodb_uri: str = "mongodb://localhost:27017/", config_path: str = "config.yaml"):
        """Initialize PDFProcessor with MongoDB connection."""
        # Load config file
        with open(config_path, 'r') as file:
            config = yaml.safe_load(file)
            
        self.client = MongoClient(mongodb_uri)
        self.db = self.client.knowledge_base
        self.collection = self.db.documents
        
        self.model = SentenceTransformer(config['embedding_model'])
        
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1024,
            chunk_overlap=100
        )

    def process_pdf_directory(self, pdf_dir: str) -> List[Dict]:
        """Process all PDFs in a directory and return their chunks with embeddings."""
        processed_chunks = []
        
        pdf_files = [f for f in os.listdir(pdf_dir) if f.endswith('.pdf')]
        
        for pdf_file in pdf_files:
            pdf_path = os.path.join(pdf_dir, pdf_file)
            logger.info(f"Processing {pdf_file}")
            
            try:

                chunks = self._process_single_pdf(pdf_path)
                processed_chunks.extend(chunks)
                logger.info(f"Successfully processed {pdf_file}")
            except Exception as e:
                logger.error(f"Error processing {pdf_file}: {str(e)}")
                continue
        
        return processed_chunks

    def _process_single_pdf(self, pdf_path: str) -> List[Dict]:
        """Process a single PDF file and return chunks with embeddings."""
        docs = PyPDFLoader(file_path=pdf_path).load()
        
        chunks = self.text_splitter.split_documents(docs)
        
        processed_chunks = []
        for chunk in chunks:

            embedding = self.model.encode(chunk.page_content)

            embedding_list = embedding.tolist()
            
            processed_chunk = {
                "content": chunk.page_content,
                "embedding": embedding_list,
                "metadata": {
                    "source": chunk.metadata.get("source"),
                    "page": chunk.metadata.get("page"),
                }
            }
            processed_chunks.append(processed_chunk)
        
        return processed_chunks

    def save_to_mongodb(self, chunks: List[Dict]) -> None:
        """Save processed chunks to MongoDB."""
        if not chunks:
            logger.warning("No chunks to save")
            return
        
        try:

            self.collection.create_index([("embedding", "2dsphere")])
            
            result = self.collection.insert_many(chunks)
            logger.info(f"Successfully saved {len(result.inserted_ids)} chunks to MongoDB")
        except Exception as e:
            logger.error(f"Error saving to MongoDB: {str(e)}")

    def process_and_save_pdfs(self, pdf_dir: str) -> None:
        """Process all PDFs in directory and save to MongoDB."""
        chunks = self.process_pdf_directory(pdf_dir)
        self.save_to_mongodb(chunks)

def main():
    processor = PDFProcessor()
    pdf_dir = "pdf/"
    processor.process_and_save_pdfs(pdf_dir)

if __name__ == "__main__":
    main()