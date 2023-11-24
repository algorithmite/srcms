use axum::{routing::get, Router};
use shuttle_secrets::SecretStore;
use sqlx::PgPool;
use std::path::PathBuf;
use tower_http::services::ServeDir;

async fn hello_world() -> &'static str {
    "Hello, world!"
}

#[shuttle_runtime::main]
async fn axum(
    #[shuttle_shared_db::Postgres(
        local_uri = "postgres://postgres:{secrets.PASSWORD}@localhost:5433/postgres"
    )]
    _pool: PgPool,
    #[shuttle_secrets::Secrets] _secret_store: SecretStore,
) -> shuttle_axum::ShuttleAxum {
    let router = Router::new()
        .route("/", get(hello_world))
        .nest_service("/static", ServeDir::new(PathBuf::from("assets")));

    Ok(router.into())
}
