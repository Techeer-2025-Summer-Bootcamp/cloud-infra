from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class BoardBase(BaseModel):
    title: str
    content: str
    author: str

class BoardCreate(BoardBase):
    pass

class Board(BoardBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        orm_mode = True 