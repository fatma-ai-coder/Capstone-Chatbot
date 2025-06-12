# Install necessary libraries if not already installed
# pip install pymupdf faiss-cpu nltk transformers

import fitz  # PyMuPDF
import faiss
import nltk
from transformers import AutoTokenizer, AutoModel
import numpy as np
import pickle

# Download NLTK sentence tokenizer
nltk.download('punkt')
nltk.download('punkt_tab')

# Load the pre-trained model and tokenizer
tokenizer = AutoTokenizer.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")
model = AutoModel.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")

# Step 1: Extract text from PDF
def extract_text_from_pdf(pdf_path):
    text = ""
    with fitz.open(pdf_path) as pdf:
        for page in pdf:
            text += page.get_text()
    return text

# Step 2: Chunk the extracted text
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


# Step 3: Embed chunks into vectors
def embed_text(chunks):
    embeddings = []
    for chunk in chunks:
        inputs = tokenizer(chunk, return_tensors="pt", padding=True, truncation=True)
        outputs = model(**inputs)
        embeddings.append(outputs.last_hidden_state.mean(dim=1).detach().numpy())
    return np.vstack(embeddings)

# Load and process the PDF (replace with your PDF's path)
pdf_path = "student_handbook.pdf"
document_text = extract_text_from_pdf(pdf_path)

# Chunk the document
chunks = chunk_text(document_text)

# Embed the chunks into vector form
embeddings = embed_text(chunks)

# Store embeddings using FAISS
d = embeddings.shape[1]
index = faiss.IndexFlatL2(d)
index.add(embeddings)

# Save the FAISS index and chunks locally
faiss.write_index(index, "handbook_index.faiss")
with open("handbook_chunks.pkl", "wb") as f:
    pickle.dump(chunks, f)

print("PDF text extracted, indexed, and stored.")
