from datetime import datetime, timedelta, timezone
from jose import jwt
from passlib.context import CryptContext
import os

PWD_CTX=CryptContext(schemes=['bcrypt'],deprecated="auto")
SECRET_KEY= os.getenv('SECRET_KEY',"please change this secret")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7

def hash_password(password: str) -> str:
    return PWD_CTX.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return PWD_CTX.verify(plain, hashed)

def create_access_token(sub: str, minutes: int = ACCESS_TOKEN_EXPIRE_MINUTES):
    expire = datetime.now(timezone.utc) + timedelta(minutes=minutes)
    payload = {"sub":str(sub),"exp":expire.isoformat()}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def decode_access_token(token: str):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except Exception:
        return None



