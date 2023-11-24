use std::sync::Arc;
use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use serde_json::json;

use srcms_data::users::{User, CreateUser, UpdateUser};
use crate::common::{AppState, FilterOptions, ParamOptions};



pub async fn user_list_handler(
    opts: Option<Query<FilterOptions>>,
    State(data): State<Arc<AppState>>,
) -> Result<impl IntoResponse, (StatusCode, Json<serde_json::Value>)> {
    let Query(opts) = opts.unwrap_or_default();

    let limit = opts.limit.unwrap_or(10);
    let offset = (opts.page.unwrap_or(1) - 1) * limit;

    let query_result = sqlx::query_as!(
        User,
        "SELECT * FROM users ORDER by id LIMIT $1 OFFSET $2",
        limit as i32,
        offset as i32
    )
    .fetch_all(&data.db)
    .await;

    if query_result.is_err() {
        let error_response = serde_json::json!({
            "status": "fail",
            "message": "Something bad happened while fetching users",
        });
        return Err((StatusCode::INTERNAL_SERVER_ERROR, Json(error_response)));
    }

    let user_list = query_result.unwrap();

    let json_response = serde_json::json!({
        "status": "success",
        "results": user_list.len(),
        "notes": user_list
    });

    Ok(Json(json_response))
}