# Quasar - API REST del servizio quasar-api

import flask


def create_app():
    # costruisce e restituisce l'applicazione Flask.
    # wsgi.py la crea all'avvio
    app = flask.Flask(__name__)

    # GET /  (dietro Apache diventa /quasar/)
    # radice pubblica: dice quali versioni dell'API esistono,
    @app.route("/")
    def versions():
        # jsonify trasforma il dizionario in JSON
        return flask.jsonify({
            "versions": [
                {"id": "v1", "status": "CURRENT"},
            ]
        })

    return app
