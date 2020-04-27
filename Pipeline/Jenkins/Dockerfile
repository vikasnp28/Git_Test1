FROM alpine:latest

ENV TERRAFORM_VERSION=0.12.3
ENV TERRAFORM_SHA256SUM=75e4323b8514074f8c2118ea382fc677c8b1d1730eda323ada222e0fac57f7db
ENV TERRAFORM_DOWNLOAD_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV AZURECLI_VERSION=latest

RUN apk update && \
    apk add --no-cache make jq python py-pip openssh-client unzip git gcc libffi-dev musl-dev openssl-dev python-dev curl bash python3 openssl && \
	curl -o /tmp/terraform.zip -L "${TERRAFORM_DOWNLOAD_URL}" && \
    echo "${TERRAFORM_SHA256SUM}  /tmp/terraform.zip" > /tmp/terraform.sha256sum && \
    sha256sum -cs /tmp/terraform.sha256sum && \
    unzip /tmp/terraform.zip && \
    mv terraform /bin && \
    rm /tmp/terraform.* && \
	rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python && \
	pip install --upgrade pip && \
    pip install azure-cli 