FROM                java:8

MAINTAINER          Ismar Slomic <ismar.slomic@accenture.com>

# Configuration variables.
ENV JIRA_HOME       /var/atlassian/jira
ENV JIRA_INSTALL    /opt/atlassian/jira
ENV TEMP_FOLDER     /tmp
ENV TEMP_FILE       jira.tar.gz
ENV JIRA_VERSION    7.1.9

# Install dependencies
RUN                 apt-get update && apt-get install -y curl tar xmlstarlet vim \
                    && apt-get clean

# Create the user that will run the jira instance and his home directory (also make sure that the parent directory exists)
RUN                 mkdir -p $(dirname $JIRA_HOME) \
                    && useradd -m -d $JIRA_HOME -s /bin/bash -u 547 jira

# Download and install jira in /opt with proper permissions and clean unnecessary files
RUN                 curl -Lks https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-$JIRA_VERSION.tar.gz -o $TEMP_FOLDER/$TEMP_FILE \
                    && mkdir -p $JIRA_INSTALL \
                    && tar -zxf $TEMP_FOLDER/$TEMP_FILE --strip=1 -C $JIRA_INSTALL \
                    && chown -R root:root $JIRA_INSTALL \
                    && chown -R 547:root $JIRA_INSTALL/logs $JIRA_INSTALL/temp $JIRA_INSTALL/work \
                    && rm $TEMP_FOLDER/$TEMP_FILE \
                    && sed --in-place "s/java version/openjdk version/g" "${JIRA_INSTALL}/bin/check-java.sh" \
                    && echo -e "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties"

# Add jira customizer and launcher
COPY                files/launch.sh /launch

# Make jira customizer and launcher executable
RUN                 chmod +x /launch

# Expose ports
EXPOSE              8080

# Workdir
WORKDIR             $JIRA_INSTALL

# Launch jira
ENTRYPOINT          ["/launch"]