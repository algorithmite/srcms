use chrono::prelude::*;
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Eq, Debug, Serialize, Deserialize, FromRow)]
struct User {
    id: Uuid,
    role_id: Uuid,
    email: String,
    username: String,
    auth_token: Option<String>,
    hash: String,
    modified: DateTime<Utc>,
    created: DateTime<Utc>,
    deleted: Option<DateTime<Utc>>,
}

impl PartialEq for User {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

#[derive(Debug, Serialize, Deserialize)]
struct NewUser {
    role_id: Option<Uuid>,
    email: String,
    username: String,
    auth_token: Option<String>,
    unhashed: String,
}
