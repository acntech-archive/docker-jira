FROM                java:8

MAINTAINER          Ismar Slomic <ismar.slomic@accenture.com>

# Install dependencies, download and extract JIRA Software and create the required directory layout.
# Try to limit the number of RUN instructions to minimise the number of layers that will need to be created.
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends libtcnative-1 xmlstarlet vim \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
ENV RUN_USER        daemon
ENV RUN_GROUP       daemon

# Data directory for JIRA Software
# https://confluence.atlassian.com/adminjiraserver071/jira-application-home-directory-802593036.html
ENV JIRA_HOME          /var/atlassian/application-data/jira

# Install Atlassian JIRA Software to the following location
# https://confluence.atlassian.com/adminjiraserver071/jira-application-installation-directory-802593035.html
ENV JIRA_INSTALL_DIR   /opt/atlassian/jira

ENV JIRA_VERSION       7.1.9
ENV DOWNLOAD_URL       https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz


RUN mkdir -p                             ${JIRA_INSTALL_DIR} \
    && curl -L --silent                  ${DOWNLOAD_URL} | tar -xz --strip=1 -C "$JIRA_INSTALL_DIR" \
    && mkdir -p                          ${JIRA_INSTALL_DIR}/conf/Catalina      \
    && chmod -R 700                      ${JIRA_INSTALL_DIR}/conf/Catalina      \
    && chmod -R 700                      ${JIRA_INSTALL_DIR}/logs               \
    && chmod -R 700                      ${JIRA_INSTALL_DIR}/temp               \
    && chmod -R 700                      ${JIRA_INSTALL_DIR}/work               \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR}/                   \
    && sed --in-place          "s/java version/openjdk version/g" "${JIRA_INSTALL_DIR}/bin/check-java.sh" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && ln --symbolic           "/usr/lib/x86_64-linux-gnu/libtcnative-1.so" "${JIRA_INSTALL_DIR}/lib/libtcnative-1.so"

# Add jira customizer and launcher
COPY        files/launch.sh /launch

# Make jira customizer and launcher executable
RUN         chmod +x /launch

USER        ${RUN_USER}:${RUN_GROUP}

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted
VOLUME      ["${JIRA_HOME}"]

# HTTP Port
EXPOSE      8080

WORKDIR     $JIRA_INSTALL_DIR

# Launch jira
ENTRYPOINT  ["/launch"]