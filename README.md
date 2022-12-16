# dockerized-dbt
Simple dockerized version of a dbt project that connects to Snowflake, mostly for illustrative purposes of what you can do with the image (like run it via AWS Fargate inside a Step Functions State Machine).

## Docker Hub

https://hub.docker.com/r/andrewwlane/dockerized-dbt

## DBT

The repo's dbt contents are basically the result of `dbt init` with one additional feature for audit logging.  We also
have [fixed the default behavior where `dbt test` fails with the initial code](https://github.com/AndrewLane/dockerized-dbt/commit/284b42651fd1b0102f7106bcbde83ea0bcd8efbf).
This repo also has an on-run-start hook which will create an `audit` table.  This table is just meant to have a good place to confirm whether `dbt run` ran successfully and what time that occurred.  A pre-hook does the insert into the `audit` table for every model.

## Arguments and Environment Variables

The container expects all inputs related to connecting to Snowflake to be passed in via environment variables.  In addition, the invocation expects a single command-line parameter (either `run` or `test`) such that we can either invoke `dbt run` or `dbt test`.


## Example runs:

**dbt run:**

```
>docker run -it --env-file .env andrewwlane/dockerized-dbt:latest run
```

```
Kicking off dbt run...
20:43:53  Running with dbt=1.3.1
20:43:53  Partial parse save file not found. Starting full parse.
20:43:54  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 303 macros, 1 operation, 0 seed files, 0 sources, 0 exposures, 0 metrics
20:43:54  
20:43:59  
20:43:59  Running 1 on-run-start hook
20:43:59  1 of 1 START hook: dockerized_dbt.on-run-start.0 ............................... [RUN]
20:43:59  1 of 1 OK hook: dockerized_dbt.on-run-start.0 .................................. [SUCCESS 1 in 0.68s]
20:43:59
20:44:00  Concurrency: 1 threads (target='dev')
20:44:00  
20:44:00  1 of 2 START sql table model transformed.my_first_dbt_model .................... [RUN]
20:44:02  1 of 2 OK created sql table model transformed.my_first_dbt_model ............... [SUCCESS 1 in 2.42s]
20:44:02  2 of 2 START sql view model transformed.my_second_dbt_model .................... [RUN]
20:44:04  2 of 2 OK created sql view model transformed.my_second_dbt_model ............... [SUCCESS 1 in 1.74s]
20:44:04  
20:44:04  Finished running 1 table model, 1 view model, 1 hook in 0 hours 0 minutes and 9.69 seconds (9.69s).
20:44:04  
20:44:04  Completed successfully
20:44:04
20:44:04  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
Done...
```

**dbt test**
```
>docker run -it --env-file .env andrewwlane/dockerized-dbt:latest test
```

```
Kicking off dbt test...
20:44:17  Running with dbt=1.3.1
20:44:17  Partial parse save file not found. Starting full parse.
20:44:19  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 303 macros, 1 operation, 0 seed files, 0 sources, 0 exposures, 0 metrics
20:44:19  
20:44:22  
20:44:22  Running 1 on-run-start hook
20:44:22  1 of 1 START hook: dockerized_dbt.on-run-start.0 ............................... [RUN]
20:44:23  1 of 1 OK hook: dockerized_dbt.on-run-start.0 .................................. [SUCCESS 1 in 0.70s]
20:44:23  
20:44:23  Concurrency: 1 threads (target='dev')
20:44:23  
20:44:23  1 of 4 START test not_null_my_first_dbt_model_id ............................... [RUN]
20:44:24  1 of 4 PASS not_null_my_first_dbt_model_id ..................................... [PASS in 1.26s]
20:44:24  2 of 4 START test not_null_my_second_dbt_model_id .............................. [RUN]
20:44:27  2 of 4 PASS not_null_my_second_dbt_model_id .................................... [PASS in 2.53s]
20:44:27  3 of 4 START test unique_my_first_dbt_model_id ................................. [RUN]
20:44:28  3 of 4 PASS unique_my_first_dbt_model_id ....................................... [PASS in 1.25s]
20:44:28  4 of 4 START test unique_my_second_dbt_model_id ................................ [RUN]
20:44:29  4 of 4 PASS unique_my_second_dbt_model_id ...................................... [PASS in 1.49s]
20:44:29  
20:44:29  Finished running 4 tests, 1 hook in 0 hours 0 minutes and 10.06 seconds (10.06s).
20:44:29  
20:44:29  Completed successfully
20:44:29
20:44:29  Done. PASS=4 WARN=0 ERROR=0 SKIP=0 TOTAL=4
Done...
```

## Example contents of .env file:

```
DBT_SNOWFLAKE_ACCOUNT=xxxxxx.us-east-1
DBT_SNOWFLAKE_DATABASE=your_db_here
DBT_PASSWORD=password_here
DBT_ROLE=role_here
DBT_SCHEMA=schema_here
DBT_USER=your_user_here
DBT_WAREHOUSE=warehouse_here
```

## Example audit records in Snowflake after successful run:

```
>select * from audit order by time desc limit 2;
+---------------------+---------------------------+-------------------------------+
| MODEL               | STATE                     | TIME                          |
|---------------------+---------------------------+-------------------------------|
| my_second_dbt_model | starting model deployment | 2022-11-16 11:30:18.021 -0800 |
| my_first_dbt_model  | starting model deployment | 2022-11-16 11:30:15.090 -0800 |
+---------------------+---------------------------+-------------------------------+
```

## See also

https://github.com/AndrewLane/dbt-fargate-poc
