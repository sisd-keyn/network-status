import sqlite3
from datetime import date, timedelta

DB_PATH = "/var/lib/docker/volumes/ping_data/_data/pings.db"

connection = sqlite3.connect(DB_PATH)
cur = connection.cursor()

start = date(2026, 10, 1)
for i in range(5):  # Oct 1 through Oct 5
    day_start = start + timedelta(days=i)
    day_end = day_start + timedelta(days=1)

    cur.execute(
        "SELECT COUNT(*) FROM pings WHERE timestamp >= ? AND timestamp < ?",
        (f"{day_start.isoformat()}T00:00:00Z", f"{day_end.isoformat()}T00:00:00Z"),
    )
    count = cur.fetchone()[0]
    print(day_start, count)

connection.close()
