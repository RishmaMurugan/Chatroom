from datetime import datetime
import uuid
import psycopg2
import psycopg2.extras

hostname = "localhost"
database = "chatroom"
user = "postgres"
db_password="test1234"
port_id = 5432
conn = None

def createMessage(sender_id, content):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # cur.execute('DROP TABLE IF EXISTS messages')
                create_script = ''' 
                    CREATE TABLE IF NOT EXISTS messages (
                        id UUID PRIMARY KEY,
                        content text NOT NULL,
                        sendTime TIMESTAMP NOT NULL,
                        senderId UUID NOT NULL
                    )
                '''
                cur.execute(create_script)
                insert_script = 'INSERT INTO messages (id, content, sendTime, senderId) VALUES (%s, %s, %s, %s)'
                message_id = uuid.uuid4()
                insert_value = (message_id, content, datetime.now(), sender_id)
                cur.execute(insert_script, insert_value)
                return message_id, 200

    except Exception as error:
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()


def getMessage(message_id):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                get_pw_script = 'SELECT id, content, sendTime, senderId FROM messages WHERE id=%s'
                cur.execute(get_pw_script, (message_id, ))
                res = cur.fetchall()
                conversation = {"id": str(res[0][0]), "content": res[0][1], "sendTime": str(res[0][2]), "senderId": str(res[0][3])}
                if res is not None:
                    return conversation, 200
                else:
                    return "Invalid username", 401
    except Exception as error:
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()



# cur.execute('DROP TABLE IF EXISTS users')
