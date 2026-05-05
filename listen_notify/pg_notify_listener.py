import asyncio
import asyncpg
from routes import clients

async def notify_callback(connection, pid, channel, payload):
    # print(f"Received notification on channel '{channel}': {payload} with pid {pid} and connection {connection}")
    for ws in clients.copy():
        try:
            await ws.send_text(payload)
        except Exception as e:
            print(f"Error sending notification to client: {e}")
            clients.discard(ws)


async def listen_to_notifications(dsn):
    dsn = dsn.replace("postgresql+psycopg2://", "postgresql://")
    try:
        conn = await asyncpg.connect(dsn)
        # print(f"Connected to database with DSN: {dsn}")
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return
    await conn.add_listener('my_channel', notify_callback)
    try:
        while True:
            await asyncio.sleep(1)  # Keep the connection alive
    finally:
        await conn.close()