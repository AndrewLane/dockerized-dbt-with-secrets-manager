FROM python:3.8.15-slim

RUN pip install dbt-snowflake==1.3.0

RUN pip install awscli

RUN apt update && apt install jq git -y

WORKDIR /dbt

ADD dockerized_dbt /dbt

COPY dbt.sh /

RUN dbt deps
ENTRYPOINT ["/bin/bash", "/dbt.sh"]