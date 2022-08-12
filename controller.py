import uuid
from venv import create
import psycopg2
import psycopg2.extras

hostname = "localhost"
database = "chatroom"
user = "postgres"
password="test1234"
port_id = 5432
conn = None

def createUser(username, encrypted_password):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # cur.execute('DROP TABLE IF EXISTS users')

                create_script = ''' 
                    CREATE TABLE IF NOT EXISTS users (
                        id UUID PRIMARY KEY,
                        username varchar(40) UNIQUE NOT NULL,
                        password varchar(40) NOT NULL
                    );
                '''
                cur.execute(create_script)

                insert_script = 'INSERT INTO users (id, username, password) VALUES (%s, %s, %s)'
                insert_value = (uuid.uuid4(), username, encrypted_password)
                cur.execute(insert_script, insert_value)

                cur.execute('SELECT * FROM USERS')
                for record in cur.fetchall():
                    print(record['id'], record['username'])

    except Exception as error:
        print(error)

    finally:
        if conn is not None:
            conn.close()
