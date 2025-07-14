from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
from . import models, schemas, database

# 데이터베이스 테이블 생성
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "FastAPI Board API"}

@app.post("/boards/", response_model=schemas.Board)
def create_board(board: schemas.BoardCreate, db: Session = Depends(database.get_db)):
    db_board = models.Board(**board.dict())
    db.add(db_board)
    db.commit()
    db.refresh(db_board)
    return db_board

@app.get("/boards/", response_model=List[schemas.Board])
def get_boards(db: Session = Depends(database.get_db)):
    boards = db.query(models.Board).all()
    return boards

