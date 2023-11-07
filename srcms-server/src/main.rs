use poem::{endpoint::StaticFilesEndpoint, get, handler, Route};
use shuttle_poem::ShuttlePoem;
use shuttle_secrets::SecretStore;
use sqlx::PgPool;

#[handler]
fn hello_world() -> &'static str {
    "Hello, world!"
}

#[shuttle_runtime::main]
async fn poem(
    #[shuttle_shared_db::Postgres(
        local_uri = "postgres://postgres:{secrets.PASSWORD}@localhost:5433/postgres"
    )]
    _pool: PgPool,
    #[shuttle_secrets::Secrets] _secret_store: SecretStore,
) -> ShuttlePoem<impl poem::Endpoint> {
    let app = Route::new().at("/", get(hello_world)).nest(
        "/static",
        StaticFilesEndpoint::new("./static").show_files_listing(),
    );
    Ok(app.into())
}
