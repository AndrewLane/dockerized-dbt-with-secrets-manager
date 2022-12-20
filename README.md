# dockerized-dbt-with-secrets-manager
Simple dockerized version of a dbt project that pulls credential info from AWS Secrets Manager in order to connect to Snowflake, mostly for illustrative purposes of what you can do with the image (like run it via AWS Fargate inside a Step Functions State Machine).

Forked from https://github.com/AndrewLane/dockerized-dbt

## Docker Hub

https://hub.docker.com/r/andrewwlane/dockerized-dbt-with-secrets-manager

## DBT

The repo's dbt contents are basically the result of `dbt init` with one additional feature for audit logging.  We also
have [fixed the default behavior where `dbt test` fails with the initial code](https://github.com/AndrewLane/dockerized-dbt/commit/284b42651fd1b0102f7106bcbde83ea0bcd8efbf).
This repo also has an on-run-start hook which will create an `audit` table.  This table is just meant to have a good place to confirm whether `dbt run` ran successfully and what time that occurred.  A pre-hook does the insert into the `audit` table for every model.

## Arguments and Environment Variables

The container expects to use keypair auth to authenticate to Snowflake.

The container expects a couple secrets to be set up in AWS secrets manager.  One is for the contents of profiles.yml, and the other is the actual private key contents.
The names of the secrets are referenced in environment variables DBT_PROFILES_YML_SECRET_NAME and DBT_PRIVATE_KEY_SECRET_NAME.

In addition, the invocation expects a single command-line parameter (either `debug` or `run` or `test`) such that we can either invoke `dbt debug` or `dbt run` or `dbt test`.


## Example runs:

**dbt run:**

```
>docker run -it --env-file .env andrewwlane/dockerized-dbt-with-secrets-manager:latest run
```

```

```

**dbt test**
```
>docker run -it --env-file .env andrewwlane/dockerized-dbt-with-secrets-manager:latest test
```

```

```

## Example contents of .env file:

```
AWS_DEFAULT_REGION=us-east-1
AWS_ACCESS_KEY_ID=xxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxx
DBT_PROFILES_YML_SECRET_NAME=dev/snowflake/dbt/profiles_yml
DBT_PRIVATE_KEY_SECRET_NAME=dev/snowflake/dbt/private_key
```

## Example plaintext content of secret pointed by DBT_PROFILES_YML_SECRET_NAME above

```
config:
   use_colors: false

dockerized_dbt:
  outputs:
    dev:
      account: xxxxx.us-east-1
      database: db_here
      private_key_path: /root/.ssh/rsa_key.p8
      private_key_passphrase: xxxxx

      role: role_here
      schema: schema_here
      threads: 1
      type: snowflake
      user: user_here
      warehouse: warehouse_here
  target: dev
```

## Example audit records in Snowflake after successful run:

```
>select * from audit order by time desc limit 2;

```

## See also

https://github.com/AndrewLane/dbt-fargate-poc
https://github.com/AndrewLane/dockerized-dbt