FROM python:3.8.15-slim

RUN pip install dbt-snowflake==1.3.0

COPY config/profiles.dist.yml /root/.dbt/profiles.yml

WORKDIR /dbt

ADD dockerized_dbt /dbt

COPY dbt.sh /

RUN dbt deps
ENTRYPOINT ["/bin/bash", "/dbt.sh"]