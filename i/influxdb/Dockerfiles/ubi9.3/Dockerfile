FROM registry.access.redhat.com/ubi9/ubi:9.3 AS builder


ARG VERSION=2.7.11
ENV DEBIAN_FRONTEND=noninteractive
ENV SOURCE_ROOT=/tmp
ENV GOPATH=/root/go
ENV PATH=$PATH:$GOPATH/bin

WORKDIR /tmp
RUN dnf install -y dnf-utils wget && \
    dnf clean all

# Add CentOS Stream 9 CRB, AppStream, and BaseOS repos
RUN dnf config-manager --add-repo https://mirror.stream.centos.org/9-stream/CRB/s390x/os/ && \
    dnf config-manager --add-repo https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/ && \
    dnf config-manager --add-repo https://mirror.stream.centos.org/9-stream/BaseOS/s390x/os/

# Import CentOS GPG key
RUN wget http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official && \
    mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/ && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official

# Install dependencies
RUN dnf install -y --allowerasing \
    clang git gcc gcc-c++ wget \
    protobuf protobuf-devel tar curl patch \
    pkg-config make nodejs python3 gawk && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    dnf clean all
RUN ln -sf /usr/bin/python3 /usr/bin/python	
# Install Yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash && \
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    export PATH="$HOME/.cargo/bin:$PATH" && \
    wget https://storage.googleapis.com/golang/go1.22.10.linux-s390x.tar.gz && \
    tar -C /usr/local -xzf go1.22.10.linux-s390x.tar.gz && \
    export PATH=/usr/local/go/bin:$PATH && \
    export GO111MODULE=on && \
    go install github.com/influxdata/pkg-config@v0.2.13 && \
    git clone -b v${VERSION} https://github.com/influxdata/influxdb.git && \
    cd influxdb && \
    export PATH=$PATH:/usr/local/go/bin:$HOME/.cargo/bin && \
    export NODE_OPTIONS=--max_old_space_size=4096 && \
    make
# Final image
FROM registry.access.redhat.com/ubi9/ubi:9.3

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

COPY --from=builder /tmp/influxdb/bin/linux/influxd /usr/bin/influxd

EXPOSE 8086

ENTRYPOINT [ "/usr/bin/influxd" ]
