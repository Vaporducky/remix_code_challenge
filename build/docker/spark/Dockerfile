FROM docker.io/bitnami/spark:3.5.1

LABEL maintainer="aesthetic.datum@gmail.com" \
      description="Spark + Postgres JDBC + Custom code"

ENV POSTGRES_JAR_VERSION=42.7.3 \
    POSTGRES_JAR_URL=https://jdbc.postgresql.org/download

USER root

RUN pip install PyYAML
RUN mkdir /opt/bitnami/code
RUN install_packages curl wget \
    && wget ${POSTGRES_JAR_URL}/postgresql-${POSTGRES_JAR_VERSION}.jar -P /opt/bitnami/spark/jars/

USER 1001

COPY ./code /opt/bitnami/code

ENTRYPOINT ["bash"]
