FROM odoo:12.0
MAINTAINER numigi <contact@numigi.com>

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        git-core \
        python3-dev \
    && \
    git config --global user.name "Odoo" && \
    git config --global user.email "root@localhost" && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install pip==18.0 wheel==0.32.1

COPY docker_files/extended_entrypoint.sh \
    docker_files/requirements.txt \
    gitoo.yml \
    gitoo-addons.yml \
    /
COPY patches patches

RUN pip3 install -r /requirements.txt && rm /requirements.txt

ENV ODOO_DIR /usr/lib/python3/dist-packages/
RUN gitoo install-all --conf_file /gitoo.yml --destination "${ODOO_DIR}"
RUN gitoo install-all --conf_file /gitoo-addons.yml --destination "${ODOO_DIR}/odoo/addons"

# Files to run the tests
# run_pytest to run the test with pytest-odoo
COPY ./docker_files/run_pytest.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run_pytest.sh
# required for pytest-odoo
ENV OPENERP_SERVER "${ODOO_RC}"
# Configuration of the coverage report
COPY ./.coveragerc .

COPY docker_files/odoo.conf docker_files/odoo_specific.conf /etc/odoo/

RUN chmod +x /extended_entrypoint.sh
ENTRYPOINT ["/extended_entrypoint.sh"]
CMD ["odoo"]
EXPOSE 8069 8071
USER odoo
