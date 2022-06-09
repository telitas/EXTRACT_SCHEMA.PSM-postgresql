ARG postgres_version=latest
ARG pgtap_version=1.2.0
FROM postgres:${postgres_version}
ARG pgtap_version

LABEL dev.telitas.project.repository="https://github.com/telitas/postgresql-with-pgtap.docker"
LABEL dev.telitas.base.repository="https://hub.docker.com/_/postgres"

RUN apt-get update && \
    apt-get install -y make patch unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cpan TAP::Parser::SourceHandler::pgTAP

ADD https://api.pgxn.org/dist/pgtap/${pgtap_version}/pgtap-${pgtap_version}.zip /tmp/
RUN unzip /tmp/pgtap-${pgtap_version}.zip -d /tmp/ && \
    mv /tmp/pgtap-${pgtap_version} /tmp/pgtap && \
    make --directory=/tmp/pgtap && \
    make install --directory=/tmp/pgtap && \
    # make installcheck --directory=/tmp/pgtap && \
    rm -rf /tmp/*
