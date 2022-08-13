from datetime import datetime
import uuid
import psycopg2
import psycopg2.extras
import hashlib


def createMessage(senderId, content):
    hostname = "localhost"
    database = "chatroom"
    user = "postgres"
    db_password="test1234"
    port_id = 5432
    conn = None
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                cur.execute('DROP TABLE IF EXISTS messages')

                create_script = ''' 
                    CREATE TABLE IF NOT EXISTS messages (
                        id UUID PRIMARY KEY,
                        content text NOT NULL,
                        sendTime TIMESTAMP NOT NULL
                    )
                '''
                cur.execute(create_script)
                insert_script = 'INSERT INTO messages (id, content, sendTime) VALUES (%s, %s, %s)'
                message_id = uuid.uuid4()
                insert_value = (message_id, content, datetime.now())
                cur.execute(insert_script, insert_value)
                return message_id, 200

    except Exception as error:
        print(error)
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()



# cur.execute('DROP TABLE IF EXISTS users')
