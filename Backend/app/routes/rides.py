from fastapi import APIRouter, Depends, HTTPException, Query
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


@router.post("/")
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

@router.get("/user/{user_id}")
def get_user_rides(user_id: int, user=Depends(get_current_user)):
    # Secure: do not allow users to fetch others' rides
    user_id = user["id"]

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            """
            SELECT
                r.id,
                r.from_addr AS `from`,
                r.to_addr AS `to`,
                r.amount,
                r.date AS `date`,
                r.time AS `time`,
                r.seats AS availableSeats,
                r.car_name,
                r.car_number,
                r.car_color,
                u.name AS driverName,
                u.phone AS driverContact
            FROM rides r
            LEFT JOIN users u ON u.id = r.driver_id
            WHERE r.driver_id = %s
            ORDER BY r.created_at DESC
            """,
            (user_id,)
        )
        rows = cursor.fetchall()

        # reshape to match Flutter
        for ride in rows:
            ride["carDetails"] = {
                "name": ride.pop("car_name"),
                "number": ride.pop("car_number"),
                "color": ride.pop("car_color"),
            }

        return {"success": True, "rides": rows}
    finally:
        cursor.close()
        conn.close()

@router.get("/nearby")
def get_nearby_rides(
    latitude: float = Query(...),
    longitude: float = Query(...),
    radius: int = Query(10),
    user: dict = Depends(get_current_user),
):
    """
    Returns ALL scheduled rides in the app.
    For now we ignore latitude/longitude and radius and just
    give a global feed that matches the RideScreen UI shape.
    """

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            """
            SELECT
                r.id,
                r.from_addr   AS from_addr,
                r.to_addr     AS to_addr,
                r.date   AS ride_date,
                r.time   AS ride_time,
                r.seats       AS seats,
                r.amount      AS amount,
                r.car_name    AS car_name,
                r.car_number  AS car_number,
                r.car_color   AS car_color,
                u.name        AS driver_name
            FROM rides r
            JOIN users u ON u.id = r.driver_id
            WHERE r.status = 'scheduled'
            ORDER BY r.ride_date, r.ride_time
            """
        )
        rows = cursor.fetchall()

        rides = []
        for row in rows:
            # --- date formatting ---
            # If ride_date is a date object, pretty print as "27 Oct 2025"
            ride_date = row.get("date")
            if isinstance(ride_date, (date, datetime)):
                date_str = ride_date.strftime("%d %b %Y")
            else:
                # if it's already a string, just use it
                date_str = ride_date or ""

            # --- time formatting ---
            # If ride_time is a time object, pretty print as "10:30 AM"
            ride_time = row.get("time")
            if isinstance(ride_time, (time, datetime)):
                time_str = ride_time.strftime("%I:%M %p")  # 12h with AM/PM
            else:
                time_str = ride_time or ""

            # Build object matching your Flutter UI keys
            rides.append(
                {
                    "id": row["id"],
                    "from": row["from_addr"],
                    "to": row["to_addr"],
                    "date": date_str,
                    "time": time_str,
                    "seats": row["seats"],
                    "amount": row["amount"],
                    "carName": row["car_name"],
                    "carNumber": row["car_number"],
                    "carColor": row["car_color"],
                    "driver": row["driver_name"],
                    # You don't have ratings/images in DB yet, so we fake them for now
                    "rating": 4.5,
                    "driverImage": (
                        "https://i.pravatar.cc/150?u=" + row["driver_name"]
                    ),
                }
            )

        return {"success": True, "rides": rides}
    finally:
        cursor.close()
        conn.close()
