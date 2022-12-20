# expecting either "run" or "test" as first argument

set -e # exit if the dbt command fails or if we cannot look up the credentials successfully

echo "Looking up secret ${DBT_PROFILES_YML_SECRET_NAME} for the profiles.yml configuration..."
aws secretsmanager get-secret-value --secret-id ${DBT_PROFILES_YML_SECRET_NAME} | jq -r ".SecretString" --unbuffered > profiles.yml
echo "Finished writing profiles.yml."

echo "Looking up secret ${DBT_PRIVATE_KEY_SECRET_NAME} for the private key data..."
mkdir /root/.ssh && aws secretsmanager get-secret-value --secret-id ${DBT_PRIVATE_KEY_SECRET_NAME} | jq -r ".SecretString" --unbuffered > /root/.ssh/rsa_key.p8
echo "Finished lookup of private key and writing it to disk."

echo "Kicking off dbt $1..."
dbt $1
echo "Done..."