# app/chat.py
import socketio
from typing import Dict
from app.database import get_connection

# Async Socket.IO server for ASGI (FastAPI)
sio = socketio.AsyncServer(
    async_mode="asgi",
    cors_allowed_origins="*",  # dev only; restrict in production
)

# userId -> sid
user_to_sid: Dict[str, str] = {}
# sid -> userId
sid_to_user: Dict[str, str] = {}


async def save_message_to_db(sender_id: str, receiver_id: str, message: str) -> None:
    """Store chat message in MySQL."""
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            """
            INSERT INTO chat_messages (sender_id, receiver_id, message)
            VALUES (%s, %s, %s)
            """,
            (sender_id, receiver_id, message),
        )
        conn.commit()
    finally:
        cursor.close()
        conn.close()


# --------------- Socket.IO events -----------------

@sio.event
async def connect(sid, environ, auth):
    print(f"🔌 Client connected: {sid}")


@sio.event
async def disconnect(sid):
    print(f"🔌 Client disconnected: {sid}")
    # Remove from maps
    user_id = sid_to_user.pop(sid, None)
    if user_id:
        user_to_sid.pop(user_id, None)
        print(f"❌ User {user_id} unregistered (sid={sid})")


@sio.event
async def register(sid, user_id):
    """
    Called from Flutter after connecting:
    socket.emit('register', userId);
    """
    user_id = str(user_id)
    user_to_sid[user_id] = sid
    sid_to_user[sid] = user_id
    print(f"✅ User {user_id} registered with socket id {sid}")


@sio.event
async def sendMessage(sid, data):
    """
    Flutter emits:
      socket.emit('sendMessage', {
        'senderId': userId,
        'receiverId': receiverId,
        'message': message,
      });
    """

    sender_id = str(data.get("senderId"))
    receiver_id = str(data.get("receiverId"))
    message = data.get("message")

    if not sender_id or not receiver_id or not message:
        print("⚠️ Invalid sendMessage payload:", data)
        return

    print(f"💬 Message from {sender_id} to {receiver_id}: {message}")

    # 1) Save message in DB
    await save_message_to_db(sender_id, receiver_id, message)

    # 2) Send to receiver if online
    receiver_sid = user_to_sid.get(receiver_id)
    if receiver_sid:
        await sio.emit(
            "receiveMessage",
            {
                "senderId": sender_id,
                "receiverId": receiver_id,
                "message": message,
            },
            to=receiver_sid,
        )
        print(f"📨 Delivered to online user {receiver_id}")
    else:
        print(f"📭 User {receiver_id} is offline; message stored only.")

    # 3) Optionally echo back to sender (for local UI confirmation)
    await sio.emit(
        "receiveMessage",
        {
            "senderId": sender_id,
            "receiverId": receiver_id,
            "message": message,
        },
        to=sid,
    )
