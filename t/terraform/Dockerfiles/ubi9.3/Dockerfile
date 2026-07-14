FROM registry.access.redhat.com/ubi9/ubi:9.3 AS builder
ARG TERRAFORM_VERSION=v1.12.2
ARG GO_VERSION=1.24.2
ARG ARCH=s390x

# Install dependencies
RUN yum install -y wget tar git bash openssh \
    && yum clean all

# Install Go manually
WORKDIR /tmp
RUN wget -q https://storage.googleapis.com/golang/go${GO_VERSION}.linux-${ARCH}.tar.gz \
    && chmod ugo+r go${GO_VERSION}.linux-${ARCH}.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz \
    && ln -sf /usr/local/go/bin/go /usr/bin/go \
    && ln -sf /usr/local/go/bin/gofmt /usr/bin/gofmt \
    && go version

# Set Go environment
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Clone Terraform source
RUN git clone -b ${TERRAFORM_VERSION} https://github.com/hashicorp/terraform.git /go/src/github.com/hashicorp/terraform

ENV TF_DEV=true
ENV TF_RELEASE=true
WORKDIR /go/src/github.com/hashicorp/terraform
RUN /bin/bash ./scripts/build.sh

FROM registry.access.redhat.com/ubi9/ubi:9.3
ARG BIN_NAME=terraform
COPY --from=builder /go/bin/terraform /bin/terraform
COPY --from=builder /go/src/github.com/hashicorp/terraform/LICENSE /usr/share/doc/${BIN_NAME}/LICENSE.txt
WORKDIR /go
ENTRYPOINT ["/bin/terraform"]
