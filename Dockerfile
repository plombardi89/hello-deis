FROM alpine:3.4
MAINTAINER Datawire <dev@datawire.io>
LABEL PROJECT_REPO_URL = "git@github.com:datawire/hello-mobius.git" \
      PROJECT_REPO_BROWSER_URL = "https://github.com/datawire/hello-mobius" \
      DESCRIPTION = "Datawire hello-mobius" \
      VENDOR = "Datawire" \
      VENDOR_URL = "https://datawire.io/"

WORKDIR /opt/datawire/hello-mobius
COPY requirements.txt requirements-quark.txt ./

RUN apk --no-cache add \
    bash \
    build-base \
    ca-certificates \
    curl \
    linux-headers \
    ncurses \
    nginx \
    python \
    py-pip \
    py-virtualenv \
    uwsgi \
    uwsgi-python \
    wget \
  && ln -snf /bin/bash /bin/sh \
  && pip install -Ur requirements.txt pip \
  && rm requirements.txt

# Install Datawire MDK (used by Datawire Gateway)
ADD https://raw.githubusercontent.com/datawire/quark/master/install.sh .
ENV PATH $HOME/.quark/bin:$PATH
RUN bash install.sh

RUN ${HOME}/.quark/bin/quark install \
    --python $(sed -e '/^[[:space:]]*$$/d' -e '/^[[:space:]]*\#/d' requirements-quark.txt | tr '\n' ' ' ) \
    && rm requirements-quark.txt

COPY entrypoint.sh ./

COPY config/ ./config
RUN mv /opt/datawire/hello-mobius/config/nginx.conf /etc/nginx/nginx.conf

COPY service/ ./service

EXPOSE 5000
ENTRYPOINT ["./entrypoint.sh"]