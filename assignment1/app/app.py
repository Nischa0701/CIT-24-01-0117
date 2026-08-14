import os
import time
import psycopg2
from flask import Flask, render_template, request, redirect

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST", "db")
DB_NAME = os.environ.get("DB_NAME", "notesdb")
DB_USER = os.environ.get("DB_USER", "notesuser")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "notespassword")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD
    )


def init_db():
    # Retry loop in case Postgres isn't ready yet when Flask starts
    for attempt in range(10):
        try:
            conn = get_connection()
            cur = conn.cursor()
            cur.execute("""
                CREATE TABLE IF NOT EXISTS notes (
                    id SERIAL PRIMARY KEY,
                    content TEXT NOT NULL
                );
            """)
            conn.commit()
            cur.close()
            conn.close()
            print("Database ready.")
            return
        except psycopg2.OperationalError:
            print(f"Database not ready, retrying ({attempt + 1}/10)...")
            time.sleep(3)
    raise Exception("Could not connect to database after retries.")


@app.route("/", methods=["GET"])
def index():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, content FROM notes ORDER BY id DESC;")
    notes = cur.fetchall()
    cur.close()
    conn.close()
    return render_template("index.html", notes=notes)


@app.route("/add", methods=["POST"])
def add_note():
    content = request.form.get("content")
    if content:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO notes (content) VALUES (%s);", (content,))
        conn.commit()
        cur.close()
        conn.close()
    return redirect("/")


@app.route("/delete/<int:note_id>", methods=["POST"])
def delete_note(note_id):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM notes WHERE id = %s;", (note_id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect("/")


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
