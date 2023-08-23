use poem::{get, handler, Route};
use shuttle_poem::ShuttlePoem;
use shuttle_secrets::SecretStore;
use sqlx::PgPool;
use std::path::PathBuf;

#[handler]
fn hello_world() -> &'static str {
    "Hello, world!"
}

#[shuttle_runtime::main]
async fn poem(
    #[shuttle_shared_db::Postgres(
        local_uri = "postgres://postgres:{secrets.PASSWORD}@localhost:5433/postgres"
    )]
    pool: PgPool,
    #[shuttle_static_folder::StaticFolder] static_folder: PathBuf,
    #[shuttle_secrets::Secrets] secret_store: SecretStore,
) -> ShuttlePoem<impl poem::Endpoint> {
    let app = Route::new().at("/", get(hello_world));
    Ok(app.into())
}
