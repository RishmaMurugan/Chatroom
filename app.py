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
        request_data = request.get_json(force=True)
        username = request_data["username"]
        return user_controller.getUserId(username)

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
            return conversation_controller.createConversation(user_ids, message_status[0])
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


class Message(Resource):
    def post(self):
        request_data = request.get_json(force=True)
        sender_username = request_data["senderUsername"]
        sender_id = user_controller.getUserId(sender_username)
        content = request_data["content"]
        res = message_controller.createMessage(sender_id, content)
        if (res[1] == 200):
            message_id = res[0]
     

api.add_resource(User, '/user')
api.add_resource(Conversation, '/conversation')
api.add_resource(Message, '/message')

if __name__ == '__main__':
    app.run(debug=True)