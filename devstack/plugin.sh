#!/bin/bash
# Quasar - plugin DevStack

function install_quasar {
    # installazione del pacchetto Python
    :
}

function configure_quasar {
    # registra quasar nel catalogo di Keystone: nome, tipo, descrizione
    get_or_create_service "quasar" "$QUASAR_SERVICE_TYPE" "Quasar - Sensors as a Service"
}

function init_quasar {
    #avvio del servizio quasar-api
    :
}

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

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        echo_summary "Quasar: extra"
        init_quasar
    fi

    if [[ "$1" == "unstack" ]]; then
        # niente da fermare per ora
        :
    fi

    if [[ "$1" == "clean" ]]; then
        # niente da pulire per ora
        :
    fi
fi
