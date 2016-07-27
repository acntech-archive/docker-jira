#!/bin/sh

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
if [ "$(stat --format "%Y" "${JIRA_INSTALL_DIR}/conf/server.xml")" -eq "0" ]; then
    echo "${JIRA_INSTALL_DIR}/conf/server.xml has not previously been modified with custom proxy settings"

    # Backup conf/server.xml
    cp "${JIRA_INSTALL_DIR}/conf/server.xml" "${JIRA_INSTALL_DIR}/conf/server.xml.backup"

    if [ -n "${X_PROXY_NAME}" ]; then
        echo "Updating '$X_PROXY_NAME' as connector proxyName"
        xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${JIRA_INSTALL_DIR}/conf/server.xml"
    fi
    if [ -n "${X_PROXY_PORT}" ]; then
        echo "Updating '$X_PROXY_PORT' as connector proxyPort"
        xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${JIRA_INSTALL_DIR}/conf/server.xml"
    fi
    if [ -n "${X_PROXY_SCHEME}" ]; then
        echo "Updating '$X_PROXY_SCHEME' as connector scheme"
        xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${JIRA_INSTALL_DIR}/conf/server.xml"
    fi
    if [ -n "${X_PATH}" ]; then
        echo "Updating '$X_PATH' as context path"
        xmlstarlet ed --inplace --pf --ps --update '//Context/@path' --value "${X_PATH}" "${JIRA_INSTALL_DIR}/conf/server.xml"
    fi
else
    echo "Skipping modification of ${JIRA_INSTALL_DIR}/conf/server.xml as it was already modified after initial Docker image creation"
fi

# Run in foreground
exec "$@"