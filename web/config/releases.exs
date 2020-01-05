import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
application_port = String.to_integer(System.fetch_env!("APP_PORT"))

# Database
db_ssl = String.to_existing_atom(System.fetch_env!("DB_SSL"))
db_pool_size = String.to_integer(System.fetch_env!("DB_POOL_SIZE"))
db_url = System.fetch_env!("DB_URL")

# GCS
gcs_service_account_file = System.fetch_env!("GCS_SERVICE_ACCOUNT_FILE")
gcs_image_bucket = System.fetch_env!("GCS_IMAGE_BUCKET")

config :ogahunt, OgahuntWeb.Endpoint,
  http: [:inet6, port: application_port],
  url: [host: "localhost", port: application_port],
  secret_key_base: secret_key_base

# Configure your database
config :ogahunt, Ogahunt.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: db_url,
  ssl: db_ssl,
  pool_size: db_pool_size

config :ogahunt,
  gcs_service_account_file: gcs_service_account_file,
  gcs_image_bucket: gcs_image_bucket
