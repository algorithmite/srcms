use serde::{Serialize, Deserialize};
use uuid::Uuid;
use chrono::prelude::*;

#[derive(Eq, Debug, Hash, Serialize, Deserialize)]
struct User {
    id: Uuid,
    role_id: Uuid,
    email: String,
    username: String,
    auth_token: String,
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
