# expecting either "run" or "test" as first argument

echo "Kicking off dbt $1..."
dbt $1
echo "Done..."