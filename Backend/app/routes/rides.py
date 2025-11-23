from fastapi import APIRouter, Depends, HTTPException
from app.database import get_connection
from pydantic import BaseModel, Field
from app.routes.auth import get_current_user


router = APIRouter(tags=["rides"])


class CarDetails(BaseModel):
    name: str
    number: str
    color: str


class RideCreate(BaseModel):
    from_: str = Field(alias="from")
    to: str
    date: str
    time: str
    availableSeats: int
    amount: int
    carDetails: CarDetails


@router.post("")
def create_ride(data: RideCreate, user=Depends(get_current_user)):
    user_id = user["id"]

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            INSERT INTO rides
            (driver_id, from_addr, to_addr, date, time, seats, amount,
             car_name, car_number, car_color)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """,
            (
                user_id,
                data.from_,
                data.to,
                data.date,
                data.time,
                data.availableSeats,
                data.amount,
                data.carDetails.name,
                data.carDetails.number,
                data.carDetails.color,
            ),
        )
        conn.commit()
        return {"success": True}


    except Exception as e:
        print("🔥 SQL ERROR:", str(e))
        raise HTTPException(status_code=500, detail=str(e))


    finally:
        cursor.close()
        conn.close()
