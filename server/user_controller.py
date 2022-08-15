import uuid
import psycopg2
import psycopg2.extras
import hashlib
import json

f = open('db_config.json')
data = json.load(f)
hostname = data['hostname']
database = data['database']
user = data['user']
db_password = data['db_password']
port_id = data['port_id']
conn = data['conn']

def createUser(username, user_pw):
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
                    CREATE TABLE IF NOT EXISTS users (
                        id UUID PRIMARY KEY,
                        username varchar(40) UNIQUE NOT NULL,
                        password varchar(64) NOT NULL,
                        conversationIds uuid[] 
                    );
                '''
                cur.execute(create_script)

                insert_script = 'INSERT INTO users (id, username, password) VALUES (%s, %s, %s)'
                encoded_pw = hashlib.sha256(user_pw.encode('utf-8')).hexdigest()
                insert_value = (uuid.uuid4(), username, encoded_pw)
                cur.execute(insert_script, insert_value)
                return "Welcome!", 200

    except Exception as error:
        if ("duplicate key value"  in error.args[0]):
            return "Username already in use", 409
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()

def loginUser(username, input_pw):
    try:
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                get_pw_script = 'SELECT password FROM users WHERE username=%s'
                cur.execute(get_pw_script, [username,])
                encoded_input_pw = hashlib.sha256(input_pw.encode('utf-8')).hexdigest()
                encoded_correct_pw = cur.fetchone()['password']
                if encoded_input_pw == encoded_correct_pw:
                    return "Welcome!", 200
                else: 
                    return "Invalid Login Credentials - Please Try Again", 401

    except Exception as error:
        return "Invalid Login Credentials - Please Try Again", 401

    finally:
        if conn is not None:
            conn.close()

def getUserId(username):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                get_pw_script = 'SELECT id FROM users WHERE username=%s'
                cur.execute(get_pw_script, (username, ))
                id = cur.fetchone()['id']
                if id is not None:
                    return str(id), 200
                else:
                    return "Invalid username", 401

    except Exception as error:
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()

def getUsername(id):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                get_pw_script = 'SELECT username FROM users WHERE id=%s'
                cur.execute(get_pw_script, (id, ))
                username = cur.fetchone()['username']
                if username is not None:
                    return str(username), 200
                else:
                    return "Invalid username", 401

    except Exception as error:
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()

def addConversationToUser(user_id, conversation_id):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 

            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # cur.execute('DROP TABLE IF EXISTS users')
                insert_script = 'UPDATE users SET conversationIds=array_append(conversationIds,  %s) WHERE id=%s'
                insert_value = (conversation_id, user_id)
                cur.execute(insert_script, insert_value)
                return "Conversation added", 200

    except Exception as error:
        if ("duplicate key value"  in error.args[0]):
            return "Username already in use", 409
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()

def getUserConversations(username):
    try:
        psycopg2.extras.register_uuid()
        with psycopg2.connect(
            host = hostname,
            dbname = database,
            user = user,
            password = db_password,
            port = port_id) as conn: 
        
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                get_conversation_id_script = 'SELECT conversationIds FROM users WHERE username=%s'
                cur.execute(get_conversation_id_script, (username, ))
                ids = cur.fetchone()[0]
                res = []
                for id in ids:
                    res.append(str(id))
                conversation_ids = {"conversation_ids": res}
                if ids is not None:
                    return conversation_ids, 200
                else:
                    return "Invalid username", 401

    except Exception as error:
        return error.args[0], 400

    finally:
        if conn is not None:
            conn.close()

# cur.execute('DROP TABLE IF EXISTS users')
