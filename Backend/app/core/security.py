from datetime import datetime, timedelta, timezone
from jose import jwt
from passlib.context import CryptContext
import os

PWD_CTX=CryptContext(schemes=['pbkdf2_sha256'],deprecated="auto")
SECRET_KEY= os.getenv('SECRET_KEY',"please change this secret")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7

def hash_password(password: str) -> str:
    if password is None:
        password = ""
    return PWD_CTX.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    if plain is None:
        plain = ""
    return PWD_CTX.verify(plain, hashed)

def create_access_token(user_id: str) -> str:
    to_encode = {
        "sub": user_id,  # 👈 this must exist
        "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    }
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_access_token(token: str):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        return None  # so get_current_user returns "Invalid token"



