from pydantic import BaseModel

class QueryInput(BaseModel):
    question: str
    session_id: str = None
    model: str

from typing import List, Optional
from pydantic import BaseModel

class QueryResponse(BaseModel):
    answer: str
    session_id: str
    model: str
    sources: Optional[List[str]] = []  # ✅ Add this line


class DocumentInfo(BaseModel):
    file_id: str
    filename: str

class DeleteFileRequest(BaseModel):
    file_id: str
