import os
import sqlite3
 
from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
 
app = FastAPI()
templates = Jinja2Templates(directory="templates")
 
DB_PATH = os.environ.get("DB_PATH", "/data/pings.db")
 
 
def get_today_uptime():
    """Query SQLite (read-only) for today's ping success rate."""
    conn = sqlite3.connect(f"file:{DB_PATH}?mode=ro", uri=True)
    try:
        cur = conn.cursor()
        cur.execute(
            """
            SELECT COUNT(*), SUM(success)
            FROM pings
            WHERE date(timestamp) = date('now')
            """
        )
        total, successes = cur.fetchone()
    finally:
        conn.close()
 
    if not total:
        return None, 0
 
    successes = successes or 0
    uptime_pct = round((successes / total) * 100, 2)
    return uptime_pct, total
 
 
@app.get("/")
def index(request: Request):
    uptime_pct, total = get_today_uptime()
    return templates.TemplateResponse(
        "index.html",
        {"request": request, "uptime_pct": uptime_pct, "total": total},
    )
