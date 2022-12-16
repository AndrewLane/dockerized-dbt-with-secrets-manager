# dockerized-dbt
Simple dockerized version of a dbt project that connects to Snowflake, mostly for illustrative purposes of what you can do with the image (like run it via AWS Fargate inside a Step Functions State Machine).

## Docker Hub

https://hub.docker.com/r/andrewwlane/dockerized-dbt

## DBT

The repo's dbt contents are basically the result of `dbt init` with one additional feature for audit logging.  This repo also has an on-run-start hook which will create an `audit` table.  This table is just meant to have a good place to confirm whether `dbt run` ran successfully and what time that occurred.  A pre-hook does the insert into the `audit` table for every model.

## Arguments and Environment Variables

The container expects all inputs related to connecting to Snowflake to be passed in via environment variables.  In addition, the invocation expects a single command-line parameter (either `run` or `test`) such that we can either invoke `dbt run` or `dbt test`.


## Example runs:

**dbt run:**

```
>docker run -it --env-file .env andrewwlane/dockerized-dbt:latest run
```

```
Kicking off dbt run...
19:30:07  Running with dbt=1.3.0
19:30:07  Partial parse save file not found. Starting full parse.
19:30:08  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 303 macros, 1 operation, 0 seed files, 0 sources, 0 exposures, 0 metrics
19:30:08
19:30:11
19:30:11  Running 1 on-run-start hook
19:30:11  1 of 1 START hook: dockerized_dbt.on-run-start.0 ............................... [RUN]
19:30:12  1 of 1 OK hook: dockerized_dbt.on-run-start.0 .................................. [SUCCESS 1 in 0.72s]
19:30:12
19:30:12  Concurrency: 1 threads (target='dev')
19:30:12
19:30:12  1 of 2 START sql table model transformed.my_first_dbt_model .................... [RUN]
19:30:15  1 of 2 OK created sql table model transformed.my_first_dbt_model ............... [SUCCESS 1 in 2.87s]
19:30:15  2 of 2 START sql view model transformed.my_second_dbt_model .................... [RUN]
19:30:17  2 of 2 OK created sql view model transformed.my_second_dbt_model ............... [SUCCESS 1 in 2.24s]
19:30:17
19:30:17  Finished running 1 table model, 1 view model, 1 hook in 0 hours 0 minutes and 9.70 seconds (9.70s).
19:30:17
19:30:17  Completed successfully
19:30:17
19:30:17  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
Done...
```

**dbt test**
```
>docker run -it --env-file .env andrewwlane/dockerized-dbt:latest test
```

```
Kicking off dbt test...
19:30:29  Running with dbt=1.3.0
19:30:29  Partial parse save file not found. Starting full parse.
19:30:30  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 303 macros, 1 operation, 0 seed files, 0 sources, 0 exposures, 0 metrics
19:30:30
19:30:32
19:30:32  Running 1 on-run-start hook
19:30:32  1 of 1 START hook: dockerized_dbt.on-run-start.0 ............................... [RUN]
19:30:33  1 of 1 OK hook: dockerized_dbt.on-run-start.0 .................................. [SUCCESS 1 in 1.08s]
19:30:33
19:30:33  Concurrency: 1 threads (target='dev')
19:30:33
19:30:33  1 of 4 START test not_null_my_first_dbt_model_id ............................... [RUN]
19:30:37  1 of 4 FAIL 1 not_null_my_first_dbt_model_id ................................... [FAIL 1 in 3.91s]
19:30:37  2 of 4 START test not_null_my_second_dbt_model_id .............................. [RUN]
19:30:40  2 of 4 PASS not_null_my_second_dbt_model_id .................................... [PASS in 3.37s]
19:30:40  3 of 4 START test unique_my_first_dbt_model_id ................................. [RUN]
19:30:44  3 of 4 PASS unique_my_first_dbt_model_id ....................................... [PASS in 3.19s]
19:30:44  4 of 4 START test unique_my_second_dbt_model_id ................................ [RUN]
19:30:46  4 of 4 PASS unique_my_second_dbt_model_id ...................................... [PASS in 2.10s]
19:30:46
19:30:46  Finished running 4 tests, 1 hook in 0 hours 0 minutes and 16.02 seconds (16.02s).
19:30:46
19:30:46  Completed with 1 error and 0 warnings:
19:30:46
19:30:46  Failure in test not_null_my_first_dbt_model_id (models/example/schema.yml)
19:30:46    Got 1 result, configured to fail if != 0
19:30:46
19:30:46    compiled Code at target/compiled/dockerized_dbt/models/example/schema.yml/not_null_my_first_dbt_model_id.sql
19:30:46
19:30:46  Done. PASS=3 WARN=0 ERROR=1 SKIP=0 TOTAL=4
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
