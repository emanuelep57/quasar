#!/bin/bash
# Quasar - plugin DevStack

# install: installa Quasar e le dipendenze di requirements.txt
function install_quasar {
    setup_develop $QUASAR_DIR
}

# post-config: crea /etc/quasar, scrive quasar.conf e prepara uWSGI e Apache.
# install -d crea /etc/quasar gia' di proprieta' di stack (mkdir + chown in un comando),
# quasar.conf si riscrive da zero a ogni stack.sh
# configure_keystone_authtoken_middleware scrive in quasar.conf la sezione [keystone_authtoken]:
# con l'indirizzo di Keystone e credenziali dell'utente quasar
# write_uwsgi_config scrive quasar-uwsgi.ini e aggiunge ad Apache la regola
# "le richieste con /quasar vanno gestite da uWSGI".
function configure_quasar {
    sudo install -d -o $STACK_USER $QUASAR_CONF_DIR
    rm -f $QUASAR_CONF
    configure_keystone_authtoken_middleware $QUASAR_CONF quasar
    write_uwsgi_config "$QUASAR_UWSGI_CONF" "$QUASAR_UWSGI" "/quasar" "" "quasar-api"
}

# post-config: crea l'utente di servizio quasar, con il solo ruolo service nel progetto service
# (basta per controllare i token e per usare Placement, senza i permessi di admin),
# e registra Quasar nel catalogo di Keystone (servizio + endpoint).
# l'endpoint è l'indirizzo http://192.168.XXX.XXX/quasar nella regione RegionOne (default per single-region)
function create_quasar_accounts {
    create_service_user "quasar"
    get_or_create_service "quasar" "$QUASAR_SERVICE_TYPE" "Quasar - Sensors as a Service"
    get_or_create_endpoint "quasar" "$REGION_NAME" "$SERVICE_PROTOCOL://$SERVICE_HOST/quasar"
}

# extra: crea e avvia l'unita' systemd devstack@quasar-api, che lancia uWSGI.
# poi aspetta che /quasar risponda: se non risponde ferma stack.sh con un errore
function start_quasar {
    run_process "quasar-api" "$(which uwsgi) --procname-prefix quasar --ini $QUASAR_UWSGI_CONF"
    if ! wait_for_service $SERVICE_TIMEOUT $SERVICE_PROTOCOL://$SERVICE_HOST/quasar; then
        die $LINENO "quasar-api non si e' avviato"
    fi
}

# unstack: ferma il processo uWSGI
function stop_quasar {
    stop_process "quasar-api"
}

# clean: toglie la regola di Apache e il file di uWSGI
function cleanup_quasar {
    sudo rm -f $(apache_site_config_for quasar-api)
    remove_uwsgi_config "$QUASAR_UWSGI_CONF" "quasar-api"
}

# smistamento: $1 e' il modo (stack, unstack, clean), $2 la fase
if is_service_enabled quasar-api; then

    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        echo_summary "Quasar: pre-install"

    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        echo_summary "Quasar: install"
        install_quasar

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        # qui Keystone e' gia' attivo
        echo_summary "Quasar: post-config"
        configure_quasar
        create_quasar_accounts

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        echo_summary "Quasar: extra"
        start_quasar
    fi

    if [[ "$1" == "unstack" ]]; then
        stop_quasar
    fi

    if [[ "$1" == "clean" ]]; then
        cleanup_quasar
    fi
fi
