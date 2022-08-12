from flask import Flask, request
from flask_restful import Resource, Api
from flask_cors import CORS
import controller

app = Flask(__name__)
cors = CORS(app, resources={r"*": {"origins": "*"}})
api = Api(app)

class User(Resource):
    def post(self):
        request_data = request.get_json(force=True)
        username = request_data["username"]
        password = request_data["password"]
        print(username, password)
        controller.createUser(2, username, password)
        return (username, password)
    def get(self):
        return "Welcome to localhost:5050"

api.add_resource(User, '/user')
if __name__ == '__main__':
    app.run(debug=True)