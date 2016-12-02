# Zato

FROM ubuntu:16.04
MAINTAINER Armando Meeuwenoord <armando.meeuwenoord@gmail.com>

# Install helper programs used during Zato installation
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    python-software-properties \
    software-properties-common \
    libcurl4-openssl-dev \
    curl \
    redis-server \
    supervisor \
    nano \
    sudo

# Add the package signing key
RUN curl -s https://zato.io/repo/zato-0CBD7F72.pgp.asc | sudo apt-key add -

# Add Zato repo to your apt
# update sources and install Zato
RUN apt-add-repository https://zato.io/repo/stable/2.0/ubuntu
RUN apt-get update && apt-get install -y zato

# Setup supervisor
RUN mkdir -p /var/log/supervisor

# Create work environment for Zato 2.0.7

# Set a password for zato user
ENV workdir /opt/zato/
WORKDIR ${workdir}
RUN touch /opt/zato/zato_user_password /opt/zato/change_zato_password
RUN uuidgen > /opt/zato/zato_user_password
RUN chown zato:zato /opt/zato/zato_user_password
RUN echo 'zato':$(cat /opt/zato/zato_user_password) > /opt/zato/change_zato_password
RUN chpasswd < /opt/zato/change_zato_password

RUN mkdir ${workdir}/home
COPY . ${workdir}/home
RUN ls -lsa ${workdir}/home
RUN chmod +x ${workdir}/home/boot.sh
RUN chown -R zato:zato ${workdir}/home
COPY sudoers /etc/sudoers

# Switch to zato user and create Zato environment
USER zato

EXPOSE 17010 8183

# Get additional config files and starter scripts
WORKDIR /opt/zato
RUN sudo chmod 755 /opt/zato/home/zato_start_server \
                   /opt/zato/home/zato_start_web_admin

# Set a password for web admin and append it to a config file
WORKDIR /opt/zato
RUN touch /opt/zato/web_admin_password
RUN uuidgen > /opt/zato/web_admin_password
RUN echo 'password'=$(cat /opt/zato/web_admin_password) >> /opt/zato/update_password.config

ENV ZATO_BIN /opt/zato/*.*/bin/zato

RUN mkdir -p /opt/zato/env/qs
RUN rm -rf /opt/zato/env/qs && mkdir -p /opt/zato/env/qs

RUN if $REDIS_HOST -eq "localhost"; then sudo service redis-server start; fi

WORKDIR /opt/zato/env/qs
RUN $ZATO_BIN quickstart create . sqlite $REDIS_HOST 6379 --verbose --kvdb_password "" --cluster_name "servicebus-stack" --servers 1
RUN $ZATO_BIN from-config /opt/zato/update_password.config
RUN sed -i 's/127.0.0.1:11223/0.0.0.0:11223/g' /opt/zato/env/qs/load-balancer/config/repo/zato.config

USER root
CMD /usr/bin/supervisord -c /opt/zato/home/supervisord.conf
