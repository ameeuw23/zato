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
    ssh \
    supervisor \
    sudo 

# Add the package signing key
RUN curl -s https://zato.io/repo/zato-0CBD7F72.pgp.asc | sudo apt-key add -

# Add Zato repo to your apt
# update sources and install Zato
RUN apt-add-repository https://zato.io/repo/stable/2.0/ubuntu
RUN apt-get update && apt-get install -y zato

# Setup supervisor
RUN mkdir -p /var/log/supervisor

# Setup sshd
RUN mkdir /var/run/sshd/

# Create work environment for Zato 2.0.7

# Set a password for zato user
ENV workdir /opt/zato/
WORKDIR ${workdir}
WORKDIR /opt/zato/
ADD . ${workdir}
RUN touch /opt/zato/zato_user_password /opt/zato/change_zato_password
RUN uuidgen > /opt/zato/zato_user_password
RUN chown zato:zato /opt/zato/zato_user_password
RUN echo 'zato':$(cat /opt/zato/zato_user_password) > /opt/zato/change_zato_password
RUN chpasswd < /opt/zato/change_zato_password

# Switch to zato user and create Zato environment
USER zato

EXPOSE 22 6379 8183 17010 17011 11223

# Get additional config files and starter scripts
WORKDIR /opt/zato
RUN chmod 755 /opt/zato/zato_start_server \
              /opt/zato/zato_start_web_admin

# Set a password for web admin and append it to a config file
WORKDIR /opt/zato
RUN touch /opt/zato/web_admin_password
RUN uuidgen > /opt/zato/web_admin_password
RUN echo 'password'=$(cat /opt/zato/web_admin_password) >> /opt/zato/update_password.config

RUN boot.sh

USER root
CMD /usr/bin/supervisord -c /opt/zato/supervisord.conf
