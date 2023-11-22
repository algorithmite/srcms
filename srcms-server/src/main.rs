use poem::{
    endpoint::StaticFilesEndpoint,
    get, handler,
    session::{CookieConfig, CookieSession, Session},
    Route,
};
use poem_openapi::{param::Query, payload::Json, OpenApi, OpenApiService};
use shuttle_poem::ShuttlePoem;
use shuttle_secrets::SecretStore;
use sqlx::PgPool;

#[handler]
fn hello_world() -> &'static str {
    "Hello, world!"
}

struct Api;

#[OpenApi]
impl Api {
    #[oai(path = "/api", method = "get")]
    async fn api_index(&self, name: Query<Option<String>>) -> Json<String> {
        match name.0 {
            Some(name) => Json(format!("hello, {}!", name)),
            None => Json("hello!".to_string()),
        }
    }
}

#[shuttle_runtime::main]
async fn poem(
    #[shuttle_shared_db::Postgres(
        local_uri = "postgres://postgres:{secrets.PASSWORD}@localhost:5433/postgres"
    )]
    _pool: PgPool,
    #[shuttle_secrets::Secrets] _secret_store: SecretStore,
) -> ShuttlePoem<impl poem::Endpoint> {
    let api_service =
        OpenApiService::new(Api, "Hello World", "1.0").server("http://localhost:3000");
    // .with(CookieSession::new(CookieConfig::new()))
    let app = Route::new()
        .at("/", get(hello_world))
        .nest(
            "/static",
            StaticFilesEndpoint::new("./srcms-server/static").show_files_listing(),
        )
        .nest("/docs", api_service.swagger_ui());
    Ok(app.into())
}
