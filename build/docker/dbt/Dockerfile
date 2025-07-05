FROM ghcr.io/dbt-labs/dbt-postgres:1.9.0

USER root

COPY ../init_scripts/dbt_init.sh /usr/local/bin/dbt_init.sh
RUN chmod +x /usr/local/bin/dbt_init.sh

# The downstream volumes/project will appear at /usr/app
ENTRYPOINT ["/usr/local/bin/dbt_init.sh"]
CMD ["bash"]
