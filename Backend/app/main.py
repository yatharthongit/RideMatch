from fastapi import FastAPI
from app.routes import auth,rides, user
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="RideMatch Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # allow all origins (for testing)
    allow_credentials=True,
    allow_methods=["*"],      # allow GET, POST, OPTIONS, etc
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(rides.router, prefix="/api/rides", tags=["rides"])
app.include_router(user.router, prefix="/api/user", tags=["user"])

@app.get("/")
def home():
    return {"message": "Backend is running"}