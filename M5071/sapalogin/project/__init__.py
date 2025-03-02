from flask import Flask
from pymongo import MongoClient
from flask_login import LoginManager
from . import db, models

import os
import configparser

config = configparser.ConfigParser()
config.read(os.path.abspath(os.path.join(".ini")))

def create_app():
    app = Flask(__name__)

    app.config['SAPA_DB_URI'] = config['LOCAL']['SAPA_DB_URI']
    app.config['SAPA_DB_NAME'] = config['LOCAL']['SAPA_DB_NAME']
    app.config['SECRET_KEY'] = config['LOCAL']['SECRET_KEY']

    login_manager = LoginManager()
    login_manager.login_view = 'auth.login'
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(user_id):
        return db.get_user_by_id(user_id)
        
    # blueprint for auth routes in our app
    from .auth import auth as auth_blueprint
    app.register_blueprint(auth_blueprint)

    # blueprint for non-auth parts of app
    from .main import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return app