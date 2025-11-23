from fastapi import APIRouter, HTTPException, Depends, Header, UploadFile, File
from pydantic import BaseModel, EmailStr
from app.database import get_connection
from app.core.security import hash_password, verify_password, create_access_token, decode_access_token
import os, shutil

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
        return {"success": True, "message": "Account created successfully"}
    finally:
        cursor.close()
        conn.close()

@router.post("/login")
def login(inp: LoginIn):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id,name,email, password_hash FROM users WHERE email =  %s",(inp.email,))
        user = cursor.fetchone()
        if not user or not verify_password(inp.password, user["password_hash"]):
            raise HTTPException(status_code=401, detail="Invalid credentials")
        token = create_access_token(str(user["id"]))
        return {
            "success": True,
            "token": token,
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"],
                "phone": user.get("phone"),
            }
        }
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
        cursor.execute("SELECT id, name, email, phone, profile_url, created_at FROM users WHERE id = %s", (user_id,))
        user = cursor.fetchone()
        if not user:
            raise HTTPException(status_code=401, detail="User not found")
        return user
    finally:
        cursor.close()
        conn.close()

@router.get("/me")
def me(user:dict = Depends(get_current_user)):
    return {
        "id": user["id"],
        "name": user["name"],
        "email": user["email"],
        "profileUrl": user.get("profile_url"),
        "createdAt": user["created_at"].isoformat() if hasattr(user["created_at"], "isoformat") else str(user["created_at"]),
    }

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload-profile")
def upload_profile(
    profile: UploadFile = File(...),
    user: dict = Depends(get_current_user),
):
    filename = f"user_{user['id']}_{profile.filename}"
    filepath = os.path.join(UPLOAD_DIR, filename)

    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(profile.file, buffer)

    # Save relative URL or path in DB
    relative_url = f"/uploads/{filename}"

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            "UPDATE users SET profile_url = %s WHERE id = %s",
            (relative_url, user["id"]),
        )
        conn.commit()
    finally:
        cursor.close()
        conn.close()

    return {"success": True, "profileUrl": relative_url}


