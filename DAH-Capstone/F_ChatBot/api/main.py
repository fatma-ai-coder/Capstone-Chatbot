from langchain_openai import OpenAIEmbeddings
from fastapi import FastAPI, File, UploadFile, HTTPException
from api.pydantic_models import QueryInput, QueryResponse, DocumentInfo, DeleteFileRequest
from api.langchain_utils import get_rag_chain
from api.db_utils import (
    insert_application_logs,
    get_chat_history,
    get_all_documents,
    insert_document_record,
    delete_document_record
)
from api.chroma_utils import index_document_to_chroma, delete_doc_from_chroma
import os
import uuid
import logging
import shutil
from dotenv import load_dotenv

embedding_function = OpenAIEmbeddings(openai_api_key="sk--iIesrgwskbU4s1HxtelBn1sRt3bUvi9Tv2Dpu02M0T3BlbkFJ7aal4rANaVqWXRSI72klvx4Q4Zg7DiLslKikzi_8wA")
# Load .env from the correct path
load_dotenv(dotenv_path=r"C:\Users\Fatma\OneDrive\Documents\DAH uni\4th Year\2nd Term\4 - Capstone II\docs\.env")

# (Optional) Print to check if API Key is loaded
if os.getenv("OPENAI_API_KEY") is None:
    raise ValueError("OpenAI API key is not set in the environment or .env file.")
else:
    print("🔑 OpenAI Key Loaded")

# Set OpenAI API Key from environment variable
import openai
openai.api_key = os.getenv("OPENAI_API_KEY")

# Initialize embedding function for Langchain
embedding_function = OpenAIEmbeddings()

# Set up logging
logging.basicConfig(filename='app.log', level=logging.INFO)

# Initialize FastAPI app
app = FastAPI()

@app.post("/chat", response_model=QueryResponse)
def chat(query_input: QueryInput):
    import os
    session_id = query_input.session_id or str(uuid.uuid4())
    logging.info(f"Session ID: {session_id}, User Query: {query_input.question}, Model: {query_input.model}")

    chat_history = get_chat_history(session_id)
    rag_chain = get_rag_chain(query_input.model)

    result = rag_chain.invoke({
        "input": query_input.question,
        "chat_history": chat_history
    })

    answer = result['answer']
    sources = []

    if 'source_documents' in result:
        for doc in result['source_documents']:
            metadata = doc.metadata
            source_info = metadata.get('source') or metadata.get('file_path') or "Unknown source"
            sources.append(os.path.basename(source_info))

    insert_application_logs(session_id, query_input.question, answer, query_input.model)
    logging.info(f"Session ID: {session_id}, AI Response: {answer}, Sources: {sources}")

    return QueryResponse(
        answer=answer,
        session_id=session_id,
        model=query_input.model,
        sources=sources
    )

@app.post("/upload-doc")
def upload_and_index_document(file: UploadFile = File(...)):
    allowed_extensions = ['.pdf', '.docx', '.html']
    file_extension = os.path.splitext(file.filename)[1].lower()

    if file_extension not in allowed_extensions:
        raise HTTPException(status_code=400, detail=f"Unsupported file type. Allowed types are: {', '.join(allowed_extensions)}")

    temp_file_path = f"temp_{file.filename}"

    try:
        # Save the uploaded file to a temporary file
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        file_id = insert_document_record(file.filename)
        success = index_document_to_chroma(temp_file_path, file_id)

        if success:
            return {"message": f"File {file.filename} has been successfully uploaded and indexed.", "file_id": file_id}
        else:
            delete_document_record(file_id)
            raise HTTPException(status_code=500, detail=f"Failed to index {file.filename}.")
    finally:
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)

@app.get("/list-docs", response_model=list[DocumentInfo])
def list_documents():
    return get_all_documents()

@app.post("/delete-doc")
def delete_document(request: DeleteFileRequest):
    chroma_delete_success = delete_doc_from_chroma(request.file_id)

    if chroma_delete_success:
        db_delete_success = delete_document_record(request.file_id)
        if db_delete_success:
            return {"message": f"Successfully deleted document with file_id {request.file_id} from the system."}
        else:
            return {"error": f"Deleted from Chroma but failed to delete document with file_id {request.file_id} from the database."}
    else:
        return {"error": f"Failed to delete document with file_id {request.file_id} from Chroma."}

