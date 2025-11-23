from fastapi import APIRouter, Depends
from app.routes.auth import get_current_user

router = APIRouter()

@router.get("/profile")
def get_profile(user: dict = Depends(get_current_user)):

    return {"name": user["name"]}