"""Applicazione WSGI di Quasar, caricata da uWSGI."""

from keystonemiddleware import auth_token

from quasar import api

# keystonemiddleware davanti all'app Flask: senza un token valido risponde 401.
# La configurazione la legge dalla sezione [keystone_authtoken] di
# /etc/quasar/quasar.conf
application = auth_token.AuthProtocol(api.create_app(),
                                      {"oslo_config_project": "quasar"})
