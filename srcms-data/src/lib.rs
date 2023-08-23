use chrono::prelude::*;
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Eq, Debug, Hash, Serialize, Deserialize, FromRow)]
struct User {
    id: Uuid,
    role_id: Uuid,
    email: String,
    username: String,
    auth_token: Option<String>,
    hash: String,
    modified: DateTime<Utc>,
    created: DateTime<Utc>,
}

impl PartialEq for User {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

impl PartialOrd for User {
    fn partial_cmp(&self, other: &Self) -> std::option::Option<std::cmp::Ordering> {
        Some(self.id.cmp(&other.id))
    }
}

impl Ord for User {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.id.cmp(&other.id)
    }
}

#[derive(Debug, Hash, Serialize, Deserialize)]
struct NewUser {
    role_id: Uuid,
    email: String,
    username: String,
    auth_token: Option<String>,
    hash: String,
}
