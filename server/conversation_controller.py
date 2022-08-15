import uuid
import psycopg2
import psycopg2.extras
import json

f = open('db_config.json')
data = json.load(f)
hostname = data['hostname']
database = data['database']
user = data['user']
db_password = data['db_password']
port_id = data['port_id']
conn = data['conn']

print(hostname, database, user, db_password, port_id, conn)

def createConversation(user_ids, initialMessageId):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
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

def getConversation(conversation_id):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                get_pw_script = 'SELECT id, userIds, messageIds FROM conversations WHERE id=%s'
                cur.execute(get_pw_script, (conversation_id, ))
                res = cur.fetchall()
                user_ids = []
                for user_id in res[0][1]:
                    user_ids.append(str(user_id))
                message_ids = []
                for message_id in res[0][2]:
                    message_ids.append(str(message_id))
                conversation = {"id": str(res[0][0]), "user_ids": user_ids, "message_ids": message_ids}
                if res is not None:
                    return conversation, 200
                else:
                    return "Invalid username", 401
    except Exception as error:
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()

