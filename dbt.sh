# expecting either "run" or "test" as first argument

set -e # exit if the dbt command fails

echo "Kicking off dbt $1..."
dbt $1
echo "Done..."