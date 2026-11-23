# punto di ingresso per uWSGI
# uWSGI importa questo modulo e cerca l'oggetto "application"
# (il quasar.wsgi:application scritto in devstack/settings).

from quasar import api

application = api.create_app()
