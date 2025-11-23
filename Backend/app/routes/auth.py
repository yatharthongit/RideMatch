from adodbapi.examples.xls_read import filename
from fastapi import APIRouter, HTTPException, Depends, Header, UploadFile, File
from pydantic import BaseModel, EmailStr
from ..database import get_connection
from ..core.security import hash_password, verify_password, create_access_token, decode_access_token
import os

router =APIRouter()

class RegisterIn(BaseModel):
    name: str
    email:EmailStr
    password: str

class LoginIn(BaseModel):
    email: EmailStr
    password: str

@router.post("/register")
def register(inp: RegisterIn):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id FROM users WHERE email =  %s",(inp.email,))
        if cursor.fetchone():
            raise HTTPException(status_code=400, detail="Email already registered")
        pwd_hash = hash_password(inp.password)
        cursor.execute(
            "INSERT INTO users (name, email, password_hash) VALUES (%s, %s, %s)",
            (inp.name, inp.email, pwd_hash)
        )
        conn.commit()
        return {"success": True, "token": token}
    finally:
        cursor.close()
        conn.close()

@router.post("/login")
def login(inp: LoginIn):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id, password_hash FROM users WHERE email =  %s",(inp.email,))
        user = cursor.fetchone()
        if not user or not verify_password(inp.password, user["password_hash"]):
            raise HTTPException(status_code=401, detail="Invalid credentials")
        token = create_access_token(str(user["id"]))
        return {"success": True, "token": token}
    finally:
        cursor.close()
        conn.close()

def get_current_user(authorization:str | None = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing authorization header")
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower()!= "bearer":
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    token = parts[1]
    payload= decode_access_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    user_id = int(payload["sub"])
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id, name, email, phone FROM users WHERE id = %s", (user_id,))
        user = cursor.fetchone()
        if not user:
            raise HTTPException(status_code=401, detail="User not found")
        return user
    finally:
        cursor.close()
        conn.close()

@router.get("/me")
def me(user:dict = Depends(get_current_user)):
    return user

UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload-profile")
async def upload_profile(profile: UploadFile = File(...), user: dict = Depends(get_current_user)):
    filename= f"{user['id']}_{profile.filename}"
    path = os.path.join(UPLOAD_DIR, filename)
    with open(path, "wb") as f:
        content = await profile.read()
        f.write(content)

    return {"success": True, "message": "Profile uploaded"}


