FROM python:3.8.2-slim-buster
MAINTAINER numigi <contact@numigi.com>

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Set the version of Odoo
ENV ODOO_VERSION 12.0

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gcc \
        git-core \
        gnupg \
        libldap2-dev \
        liblz-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        node-less \
	npm \
	nodejs \
        python3-dev \
        python3-pip \
        xz-utils \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    # && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install latest postgresql-client (copied from the official odoo image)
RUN set -x; \
        echo 'deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
        && export GNUPGHOME="$(mktemp -d)" \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update  \
        && apt-get install --no-install-recommends -y postgresql-client \
        && rm -rf /var/lib/apt/lists/*

# Install rtlcss (copied from the official odoo image)
RUN set -x;\
    echo "deb http://deb.nodesource.com/node_8.x buster main" > /etc/apt/sources.list.d/nodesource.list \
    && export GNUPGHOME="$(mktemp -d)" \
    && repokey='9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/nodejs.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g rtlcss \
    && rm -rf /var/lib/apt/lists/*

RUN git config --global user.name "Odoo" && \
    git config --global user.email "root@localhost"

RUN pip3 install pip==22.3.1 wheel==0.32.1 setuptools==45.2.0

COPY docker_files/odoo-requirements.txt docker_files/extra-requirements.txt /
RUN pip3 install -r /odoo-requirements.txt -r extra-requirements.txt && \
	rm /odoo-requirements.txt /extra-requirements.txt

# Files to run the tests
# run_pytest to run the test with pytest-odoo
COPY ./docker_files/run_pytest.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run_pytest.sh

# Configuration of the coverage report
COPY ./.coveragerc .

ENV ODOO_HOME /home/odoo
RUN useradd -d "${ODOO_HOME}" -m -s /bin/bash odoo

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf
COPY --chown=odoo docker_files/odoo.conf /etc/odoo/

# required for pytest-odoo
ENV OPENERP_SERVER "${ODOO_RC}"

ENV ODOO_DATA /var/lib/odoo
ENV EXTRA_ADDONS /mnt/extra-addons
RUN mkdir -p "${ODOO_DATA}" "${EXTRA_ADDONS}" \
    && chown odoo "${ODOO_DATA}" "${EXTRA_ADDONS}"
VOLUME ["${ODOO_DATA}", "${EXTRA_ADDONS}"]

COPY docker_files/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["odoo"]

EXPOSE 8069 8071

ENV ODOO_DIR /usr/local/lib/python3.7/site-packages
COPY .odoo-source-code ${ODOO_DIR}
COPY .extra-addons ${ODOO_DIR}/odoo/addons

COPY --chown=odoo /docker_files/odoo-bin /bin/odoo
RUN chmod +x /bin/odoo

USER odoo
