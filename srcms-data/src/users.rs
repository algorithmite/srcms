use chrono::prelude::*;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub role_id: Uuid,
    pub email: String,
    pub username: String,
    pub hash: String,
    pub modified: NaiveDateTime,
    pub created: NaiveDateTime,
    pub deleted: Option<NaiveDateTime>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateUser {
    role_id: Option<Uuid>,
    email: String,
    username: String,
    unhashed: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UpdateUser {
    role_id: Option<Uuid>,
    email: Option<String>,
    username: Option<String>,
    unhashed: Option<String>,
}
