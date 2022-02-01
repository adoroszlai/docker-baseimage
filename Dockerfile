FROM debian:11.2-slim
ARG LAUNCHER_HASH=master
VOLUME /data
RUN groupadd flokkr
RUN apt update -q \
  && apt install -y \
     git \
     jq \
     netcat \
     openjdk-11-jdk \
     python3-pip \
     sudo \
     unzip \
     wget \
   && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
   && rm -rf /var/lib/apt/lists/*
RUN pip3 install robotframework robotframework-requests
RUN wget -O /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && chmod +x /usr/bin/dumb-init
RUN echo "%flokkr ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/flokkr
ENV CONF_DIR=/opt JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

WORKDIR /opt
ENV PERMISSION_FIX=true
ADD .bashrc /root/
RUN git clone https://github.com/flokkr/launcher.git && git --work-tree=/opt/launcher --git-dir=/opt/launcher/.git checkout ${LAUNCHER_HASH}
RUN find -name onbuild.sh | xargs -n1 bash -c
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/opt/launcher/launcher.sh"]
