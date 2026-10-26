FROM registry.access.redhat.com/ubi9/ubi:9.3

ARG LOGSTASH_VER=9.1.0
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV LS_JAVA_HOME=/opt/temurin21

# Install dependencies (Go installed temporarily for env2yaml)
RUN set -eux && \
    yum install -y \
        procps-ng \
        findutils \
        tar \
        gzip \
        glibc-langpack-en \
        glibc-locale-source \
        wget \
        shadow-utils \
        golang && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 || true && \
    groupadd --gid 1000 logstash && \
    useradd --uid 1000 --gid 1000 \
        --home-dir /usr/share/logstash \
        --no-create-home \
        logstash

# Build env2yaml from local source file
COPY env2yaml/env2yaml.go /go/env2yaml.go
RUN set -eux && \
    cd /go && \
    go mod init env2yaml && \
    go get gopkg.in/yaml.v2 && \
    go build -o /usr/local/bin/env2yaml env2yaml.go && \
    rm -rf /go


# Install Temurin 21 JDK
RUN mkdir -p /opt/temurin21 && \
    cd /opt/temurin21 && \
    wget -O temurin21.tar.gz https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.5_11.tar.gz && \
    tar -zxf temurin21.tar.gz --strip-components=1 && \
    rm -f temurin21.tar.gz

# Install Logstash 
RUN cd /tmp && \
    curl -Lo logstash.tar.gz https://artifacts.elastic.co/downloads/logstash/logstash-oss-${LOGSTASH_VER}-linux-aarch64.tar.gz && \
    tar zxf logstash.tar.gz -C /usr/share && \
    mv /usr/share/logstash-${LOGSTASH_VER} /usr/share/logstash && \
    rm -f logstash.tar.gz && \
    rm -rf /usr/share/logstash/jdk && \
# Fix permissions
    chown --recursive logstash:logstash /usr/share/logstash && \
    chown -R logstash:root /usr/share/logstash && \
    chmod -R g=u /usr/share/logstash && \
    find /usr/share/logstash -type d -exec chmod g+s {} \; && \
    ln -s /usr/share/logstash /opt/logstash && \
    rm -f /usr/bin/go /usr/bin/gofmt && \
    rm -rf /usr/lib/golang && \
    rm -f /usr/bin/wget /usr/bin/curl && \
    yum clean all && \
    rm -rf /var/cache/yum


WORKDIR /usr/share/logstash
ENV ELASTIC_CONTAINER=true
ENV PATH=/usr/share/logstash/bin:$LS_JAVA_HOME/bin:$PATH
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Copy Logstash config
COPY config/logstash-oss.yml config/logstash.yml
COPY config/pipelines.yml config/log4j2.properties config/log4j2.file.properties config/
COPY pipeline/default.conf pipeline/logstash.conf
RUN chown --recursive logstash:root config/ pipeline/

# Entrypoint
COPY bin/docker-entrypoint /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint

USER 1000
EXPOSE 9600 5044
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
