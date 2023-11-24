use serde::Deserialize;
use sqlx::{Pool, Postgres};

pub struct AppState {
    pub db: Pool<Postgres>,
}

#[derive(Deserialize, Debug, Default)]
pub struct FilterOptions {
    pub page: Option<usize>,
    pub limit: Option<usize>,
}

#[derive(Deserialize, Debug)]
pub struct ParamOptions {
    pub id: String,
}