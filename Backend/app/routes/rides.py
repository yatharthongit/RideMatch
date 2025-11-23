from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from ..database import get_connection
from ..routes.auth import get_current_user
from typing import Optional
from math import cos, radians

router = APIRouter(prefix="/api/rides", tags=["rides"])

class CreateRideIn(BaseModel):
    from_: str | None = None
    to: str
    seats: int
    duration: str | None = None
    amount: str | None = None

class CreateRideRaw(BaseModel):
    from_field: Optional[str] = None
    to: str
    seats: int
    duration: Optional[str] = None
    amount: Optional[str] = None

    class Config:
        fields = {"from_field":"from"}


@router.post("",status_code=201)
def create_ride(payload: CreateRideRaw, user:dict = Depends(get_current_user)):
    conn=get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO rides (`driver_id`, `from_addr`, `to_addr`, `seats`, `duration`, `amount`) VALUES (%s,%s,%s,%s,%s,%s)",
            (user["id"],payload.from_field,payload.to,payload.seats,payload.duration,payload.amount)
            )
        conn.commit()
        return {"ride_id": cursor.lastrowid}
    finally:
        cursor.close()
        conn.close()

@router.get("/nearby")
def rides_nearby(latitude: float = Query(...), longitude: float = Query(...), radius: int = Query(10)):
    conn=get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            "SELECT r.id, r.from_addr AS `from`, r.to_addr AS `to`, r.amount, u.name AS driver, r.duration, r.seats "
            "FROM rides r LEFT JOIN users u ON u.id = r.driver_id "
            "WHERE r.status = 'scheduled'"
        )
        rows=cursor.fetchall()
        return {"success": True, "rides": rows}
    finally:
        cursor.close()
        conn.close()
