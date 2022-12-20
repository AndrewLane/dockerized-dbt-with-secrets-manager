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
Looking up secret xxxxx for the profiles.yml configuration...
Finished writing profiles.yml.
Looking up secret xxxxx for the private key data...
Finished lookup of private key and writing it to disk.
Kicking off dbt run...
20:36:52  Running with dbt=1.3.1
20:36:52  Partial parse save file not found. Starting full parse.
20:36:54  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 303 macros, 1 operation, 0 seed files, 0 sources, 0 exposures, 0 metrics
20:36:54
20:36:57
20:36:57  Running 1 on-run-start hook
20:36:57  1 of 1 START hook: dockerized_dbt.on-run-start.0 ............................... [RUN]
20:36:57  1 of 1 OK hook: dockerized_dbt.on-run-start.0 .................................. [SUCCESS 1 in 0.70s]
20:36:57
20:36:58  Concurrency: 1 threads (target='dev')
20:36:58
20:36:58  1 of 2 START sql table model secretsmanagertest.my_first_dbt_model ............. [RUN]
20:37:00  1 of 2 OK created sql table model secretsmanagertest.my_first_dbt_model ........ [SUCCESS 1 in 2.64s]
20:37:00  2 of 2 START sql view model secretsmanagertest.my_second_dbt_model ............. [RUN]
20:37:02  2 of 2 OK created sql view model secretsmanagertest.my_second_dbt_model ........ [SUCCESS 1 in 2.04s]
20:37:02  
20:37:02  Finished running 1 table model, 1 view model, 1 hook in 0 hours 0 minutes and 8.65 seconds (8.65s).
20:37:02  
20:37:02  Completed successfully
20:37:02  
20:37:02  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
Done...
```

**dbt test**
```
>docker run -it --env-file .env andrewwlane/dockerized-dbt-with-secrets-manager:latest test
```

```
Looking up secret xxxxx for the profiles.yml configuration...
Finished writing profiles.yml.
Looking up secret xxxxx for the private key data...
Finished lookup of private key and writing it to disk.
Kicking off dbt test...
20:38:22  Running with dbt=1.3.1
20:38:22  Partial parse save file not found. Starting full parse.
20:38:23  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 303 macros, 1 operation, 0 seed files, 0 sources, 0 exposures, 0 metrics
20:38:23  
20:38:25  
20:38:25  Running 1 on-run-start hook
20:38:25  1 of 1 START hook: dockerized_dbt.on-run-start.0 ............................... [RUN]
20:38:26  1 of 1 OK hook: dockerized_dbt.on-run-start.0 .................................. [SUCCESS 1 in 0.66s]
20:38:26  
20:38:26  Concurrency: 1 threads (target='dev')
20:38:26  
20:38:26  1 of 4 START test not_null_my_first_dbt_model_id ............................... [RUN]
20:38:27  1 of 4 PASS not_null_my_first_dbt_model_id ..................................... [PASS in 1.28s]
20:38:27  2 of 4 START test not_null_my_second_dbt_model_id .............................. [RUN]
20:38:28  2 of 4 PASS not_null_my_second_dbt_model_id .................................... [PASS in 1.17s]
20:38:28  3 of 4 START test unique_my_first_dbt_model_id ................................. [RUN]
20:38:30  3 of 4 PASS unique_my_first_dbt_model_id ....................................... [PASS in 1.35s]
20:38:30  4 of 4 START test unique_my_second_dbt_model_id ................................ [RUN]
20:38:31  4 of 4 PASS unique_my_second_dbt_model_id ...................................... [PASS in 1.06s]
20:38:31  
20:38:31  Finished running 4 tests, 1 hook in 0 hours 0 minutes and 7.55 seconds (7.55s).
20:38:31  
20:38:31  Completed successfully
20:38:31
20:38:31  Done. PASS=4 WARN=0 ERROR=0 SKIP=0 TOTAL=4
Done...
```

## Example contents of .env file:

```
AWS_DEFAULT_REGION=us-east-1
AWS_ACCESS_KEY_ID=xxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxx
DBT_PROFILES_YML_SECRET_NAME=dev/snowflake/dbt/profiles_yml
DBT_PRIVATE_KEY_SECRET_NAME=dev/snowflake/dbt/private_key
```

## Example plaintext content of secret pointed to by DBT_PROFILES_YML_SECRET_NAME above:

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


+---------------------+---------------------------+-------------------------------+
|        MODEL        |           STATE           |             TIME              |
+---------------------+---------------------------+-------------------------------+
| my_second_dbt_model | starting model deployment | 2022-12-20T12:37:01.613-08:00 |
| my_first_dbt_model  | starting model deployment | 2022-12-20T12:36:58.751-08:00 |
+---------------------+---------------------------+-------------------------------+
```

## See also

* https://github.com/AndrewLane/dbt-fargate-poc
* https://github.com/AndrewLane/dockerized-dbt