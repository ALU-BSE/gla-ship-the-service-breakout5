import os  # unused import — triggers flake8 F401
from flask import jsonify


def register_routes(app):
    @app.route("/health")
    def health():
        return jsonify({"status": "ok", "service": "nairobipulse"})   

    @app.route("/districts")
    def districts():
        return jsonify({
            "districts": ["Westlands", "Kibera", "Karen", "Eastleigh", "Kasarani"]
        })
