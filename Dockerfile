FROM ubuntu:noble
LABEL numigi <contact@numigi.com>

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Set the version of Odoo
ENV ODOO_VERSION 18.0

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
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
    libev-dev \
    libpq-dev \
    libsasl2-dev \
    libxml2-dev \
    libxslt1-dev \
    node-less \
    python3-dev \
    libssl-dev \
    npm \
    python3-magic \
    python3-num2words \
    python3-odf \
    python3-pdfminer \
    python3-pip \
    python3-phonenumbers \
    python3-pyldap \
    python3-qrcode \
    python3-renderpm \
    python3-setuptools \
    python3-slugify \
    python3-vobject \
    python3-watchdog \
    python3-xlrd \
    python3-xlwt \
    xz-utils && \
    if [ -z "${TARGETARCH}" ]; then \
        TARGETARCH="$(dpkg --print-architecture)"; \
    fi; \
    WKHTMLTOPDF_ARCH=${TARGETARCH} && \
    case ${TARGETARCH} in \
    "amd64") WKHTMLTOPDF_ARCH=amd64 && WKHTMLTOPDF_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59  ;; \
    "arm64")  WKHTMLTOPDF_SHA=90f6e69896d51ef77339d3f3a20f8582bdf496cc  ;; \
    "ppc64le" | "ppc64el") WKHTMLTOPDF_ARCH=ppc64el && WKHTMLTOPDF_SHA=5312d7d34a25b321282929df82e3574319aed25c  ;; \
    esac \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${WKHTMLTOPDF_ARCH}.deb \
    && echo ${WKHTMLTOPDF_SHA} wkhtmltox.deb | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ noble-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g rtlcss

RUN git config --global user.name "Odoo" && \
    git config --global user.email "root@localhost"

RUN pip3 install pip==24.3.1

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
RUN mkdir -p "${ODOO_DATA}" "${EXTRA_ADDONS}" /var/log/odoo \
    && chown -R odoo:odoo "${ODOO_DATA}" "${EXTRA_ADDONS}" /var/log/odoo
VOLUME ["${ODOO_DATA}", "${EXTRA_ADDONS}"]

COPY docker_files/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["odoo"]

EXPOSE 8069 8071 8072

# ENV ODOO_DIR /usr/local/lib/python3.10/site-packages
# COPY .odoo-source-code ${ODOO_DIR}
# COPY .extra-addons ${ODOO_DIR}/odoo/addons

COPY --chown=odoo /docker_files/odoo-bin /bin/odoo
RUN chmod +x /bin/odoo

USER odoo
