from fastapi import FastAPI
from routes import auth,rides

app = FastAPI(title="RideMatch Backend (cursor-based)")
app.include_router(auth.router)
app.include_router(rides.router)
