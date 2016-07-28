FROM                java:8

MAINTAINER          Ismar Slomic <ismar.slomic@accenture.com>

# Install dependencies, download and extract JIRA Software and create the required directory layout.
# Try to limit the number of RUN instructions to minimise the number of layers that will need to be created.
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends libtcnative-1 xmlstarlet vim \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Data directory for JIRA Software
# https://confluence.atlassian.com/adminjiraserver071/jira-application-home-directory-802593036.html
ENV JIRA_HOME          /var/atlassian/application-data/jira

# Install Atlassian JIRA Software to the following location
# https://confluence.atlassian.com/adminjiraserver071/jira-application-installation-directory-802593035.html
ENV JIRA_INSTALL_DIR   /opt/atlassian/jira

ENV JIRA_VERSION       7.1.9
ENV DOWNLOAD_URL       https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz

# Create JIRA application user, can be overwritten by providing -u option in docker run
# https://docs.docker.com/engine/reference/run/#/user
ARG user=jira
ARG group=jira
ARG uid=1000
ARG gid=1000

# JIRA is running with user `jira`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $(dirname $JIRA_HOME) \
    && groupadd -g ${gid} ${group} \
    && useradd -d "$JIRA_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN mkdir -p                                ${JIRA_HOME} \
    && mkdir -p                             ${JIRA_HOME}/caches/indexes \
    && chmod -R 700                         ${JIRA_HOME} \
    && chown -R ${user}:${group}            ${JIRA_HOME} \
    && mkdir -p                             ${JIRA_INSTALL_DIR}/conf/Catalina \
    && curl -L --silent                     ${DOWNLOAD_URL} | tar -xz --strip=1 -C "$JIRA_INSTALL_DIR" \
    && chmod -R 700                         ${JIRA_INSTALL_DIR}/conf \
    && chmod -R 700                         ${JIRA_INSTALL_DIR}/logs \
    && chmod -R 700                         ${JIRA_INSTALL_DIR}/temp \
    && chmod -R 700                         ${JIRA_INSTALL_DIR}/work \
    && chown -R ${user}:${group}            ${JIRA_INSTALL_DIR}/conf \
    && chown -R ${user}:${group}            ${JIRA_INSTALL_DIR}/logs \
    && chown -R ${user}:${group}            ${JIRA_INSTALL_DIR}/temp \
    && chown -R ${user}:${group}            ${JIRA_INSTALL_DIR}/work \
    && sed --in-place                       "s/java version/openjdk version/g" "${JIRA_INSTALL_DIR}/bin/check-java.sh" \
    && echo -e                              "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && ln --symbolic                        "/usr/lib/x86_64-linux-gnu/libtcnative-1.so" "${JIRA_INSTALL_DIR}/lib/libtcnative-1.so" \
    && touch -d "@0"                        "${JIRA_INSTALL_DIR}/conf/server.xml"

COPY        docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
RUN chmod +x /docker-entrypoint.sh

USER        ${user}:${group}

# HTTP Port
EXPOSE      8080

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted
VOLUME      ["${JIRA_HOME}"]

# Set the default working directory as the installation directory.
WORKDIR     $JIRA_INSTALL_DIR

# Run Atlassian JIRA as a foreground process by default.
# See https://confluence.atlassian.com/jirakb/jira-application-startup-and-shutdown-scripts-653951272.html#JIRAapplicationStartupandShutdownScripts-StartingJIRA
CMD         ["bin/start-jira.sh", "-fg"]