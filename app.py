from flask import Flask, request, jsonify
from flask_restful import Resource, Api
from flask_cors import CORS
import uuid
import user_controller
import conversation_controller
import message_controller

app = Flask(__name__)
cors = CORS(app, resources={r"*": {"origins": "*"}})
api = Api(app)

class User(Resource):
    def post(self):
        request_data = request.get_json(force=True)
        username = request_data["username"]
        password = request_data["password"]
        return user_controller.createUser(username, password)
    def patch(self):
        request_data = request.get_json(force=True)
        username = request_data["username"]
        password = request_data["password"]
        return user_controller.loginUser(username, password)
    def get(self):
        request_data = request.args
        username = request_data["username"]
        response_status = user_controller.getUserConversations(username)
        if (response_status[1] == 200):
            return jsonify(response_status[0])
        else:
            return "Error getting conversations", 400

class Conversation(Resource):
    def post(self):
        request_data = request.get_json(force=True)
        recipient_usernames = request_data["usernames"]
        sender_username = request_data["sender_username"]
        content = request_data["content"]
        user_ids = []
        for username in recipient_usernames:
            user_id_status = user_controller.getUserId(username)
            if (user_id_status[1] == 200):
                user_ids.append(uuid.UUID(user_id_status[0]))
            else:
                return "Error getting recipient information", 400
        sender_id_status = user_controller.getUserId(sender_username)
        if (sender_id_status[1] == 200):
            user_ids.append(uuid.UUID(sender_id_status[0]))
        else: 
            return "Error getting sender information", 400
        message_status = message_controller.createMessage(sender_id_status[0], content)
        if (message_status[1] == 200):
            conversation_status = conversation_controller.createConversation(user_ids, message_status[0])
            if (conversation_status[1] == 200):
                for user_id in user_ids:
                    addConvoStatus = user_controller.addConversationToUser(user_id, conversation_status[0])
                    if (addConvoStatus[1] != 200): 
                        return "Error adding conversation to user profile", 400
                print(conversation_status[0])
                return conversation_status[0], 200
        else:
            return "Error sending message", 400

    def patch (self):
        request_data = request.get_json(force=True)
        conversation_id = request_data["conversation_id"]
        sender_username = request_data["sender_username"]
        sender_id_status = user_controller.getUserId(sender_username)
        if (sender_id_status[1] != 200):
            return "Error sending message", 400
        content = request_data["content"]
        message_status = message_controller.createMessage(sender_id_status[0], content)
        if (message_status[1] == 200):
            return conversation_controller.addMessage(message_status[0], conversation_id)
        else:
            return "Error sending message", 400
    
    def get (self):
        request_data = request.args
        id = request_data["id"]
        response_status = conversation_controller.getConversation(id)
        if (response_status[1] == 200):
            usernames = []
            for user_id in response_status[0]['user_ids']:
                username_status = user_controller.getUsername(user_id)
                if (username_status[1] == 200):
                    usernames.append(username_status[0])
            return {"id": id, "usernames": usernames, "message_ids": response_status[0]['message_ids']}, 200
        else:
            return "Error getting conversations", 400

class Message(Resource):
    def post(self):
        request_data = request.get_json(force=True)
        sender_username = request_data["senderUsername"]
        sender_id = user_controller.getUserId(sender_username)
        content = request_data["content"]
        res = message_controller.createMessage(sender_id, content)
        if (res[1] == 200):
            message_id = res[0]
    
    def get (self):
        request_data = request.args
        id = request_data["id"]
        response_status = message_controller.getMessage(id)
        if (response_status[1] == 200):
            username_status = user_controller.getUsername(response_status[0]['senderId'])
            if (username_status[1] == 200):
                return {"id": id, "content": response_status[0]['content'], 
                    "sendTime": response_status[0]['sendTime'], "senderUsername": username_status[0]}, 200
            else: 
                return "Error getting sender information", 400
        else:
            return "Error getting message", 400

    
     

api.add_resource(User, '/user')
api.add_resource(Conversation, '/conversation')
api.add_resource(Message, '/message')

if __name__ == '__main__':
    app.run(debug=True)