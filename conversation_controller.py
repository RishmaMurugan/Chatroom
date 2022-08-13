import uuid
import psycopg2
import psycopg2.extras
import hashlib


def createConversation(user_ids, initialMessageId):
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
                cur.execute('DROP TABLE IF EXISTS conversations')
                create_script = ''' 
                    CREATE TABLE IF NOT EXISTS conversations (
                        id UUID PRIMARY KEY,
                        userIds uuid[] NOT NULL,
                        messageIds uuid[] NOT NULL
                    )
                '''
                cur.execute(create_script)
                insert_script = 'INSERT INTO conversations (id, userIds, messageIds) VALUES (%s, %s, %s)'
                conversation_id = uuid.uuid4()
                messageIds = []
                messageIds.append(initialMessageId)
                insert_value = (conversation_id, user_ids, messageIds)
                cur.execute(insert_script, insert_value)
                return str(conversation_id), 200

    except Exception as error:
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()


def addMessage(message_id, conversation_id):
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
                insert_script = 'UPDATE conversations SET messageIds=array_append(messageIds,  %s) WHERE id=%s'
                insert_value = (message_id, conversation_id)
                cur.execute(insert_script, insert_value)
                return "Message added", 200

    except Exception as error:
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()




# cur.execute('DROP TABLE IF EXISTS users')
