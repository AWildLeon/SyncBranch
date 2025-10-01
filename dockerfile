FROM alpine:latest

RUN apk update
RUN apk add tini bash git openssh

# Set up SSH global defaults
RUN echo "UserKnownHostsFile /ssh/known_hosts" >> /etc/ssh/ssh_config && \
    echo "IdentityFile /ssh/ssh_key" >> /etc/ssh/ssh_config && \
    echo "User git" >> /etc/ssh/ssh_config && \
    echo "StrictHostKeyChecking accept-new" >> /etc/ssh/ssh_config
    
COPY ./scripts/syncbranch.sh /syncbranch
COPY ./scripts/init.sh /init
COPY ./scripts/lib.sh /lib.sh

RUN chmod +x /syncbranch /init

ENTRYPOINT ["tini", "/init"]