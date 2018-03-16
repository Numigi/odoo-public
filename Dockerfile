FROM odoo:11.0
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

RUN pip3 install pip==9.0.1 wheel==0.30.0

COPY docker_files/extended_entrypoint.sh \
    docker_files/requirements.txt \
    gitoo.yaml \
    /

COPY ./docker_files/run_test.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run_test.sh
RUN pip3 install -r /requirements.txt && rm /requirements.txt

RUN gitoo install_all --conf_file /gitoo.yaml --destination /usr/lib/python3/dist-packages/odoo

RUN chmod +x /extended_entrypoint.sh
ENTRYPOINT ["/extended_entrypoint.sh"]
CMD ["odoo"]

EXPOSE 8069 8071

USER odoo

