from fastapi import APIRouter, HTTPException

api_v1_router = APIRouter(prefix='/v1')

@api_v1_router.get('/hello')
def ingest_data():
  return "hello world"