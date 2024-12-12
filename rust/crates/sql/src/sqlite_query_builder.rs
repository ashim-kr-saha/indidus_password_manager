use rusqlite::types::ToSql;
use rusqlite::{Connection, Result};
use serde_json::Value;
use thiserror::Error;

use crate::{Filter, FilterOperator, Glue, HttpQuery};

#[derive(Error, Debug)]
pub enum SqliteQueryBuilderError {
    #[error("Invalid filter: {0}")]
    InvalidFilter(String),
}

#[derive(Default)]
pub struct SqLiteQueryBuilder {
    pub table: String,
    pub query: HttpQuery,
    pub params: Vec<SqliteValue>,
    pub is_analytic: bool,
    pub is_filtered: bool,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct SqliteValue(Value);

impl ToSql for SqliteValue {
    fn to_sql(&self) -> rusqlite::Result<rusqlite::types::ToSqlOutput<'_>> {
        match &self.0 {
            Value::Null => Ok(rusqlite::types::ToSqlOutput::Owned(
                rusqlite::types::Value::Null,
            )),
            Value::Bool(b) => Ok(rusqlite::types::ToSqlOutput::from(*b)),
            Value::Number(n) => {
                if let Some(i) = n.as_i64() {
                    Ok(rusqlite::types::ToSqlOutput::from(i))
                } else if let Some(f) = n.as_f64() {
                    Ok(rusqlite::types::ToSqlOutput::from(f))
                } else {
                    Err(rusqlite::Error::ToSqlConversionFailure(Box::new(
                        rusqlite::types::FromSqlError::InvalidType,
                    )))
                }
            }
            Value::String(s) => Ok(rusqlite::types::ToSqlOutput::from(s.clone())),
            _ => Err(rusqlite::Error::ToSqlConversionFailure(Box::new(
                rusqlite::types::FromSqlError::InvalidType,
            ))),
        }
    }
}

impl SqLiteQueryBuilder {
    pub fn new(table: String, query: HttpQuery) -> Self {
        Self {
            table,
            is_analytic: query.aggregates.is_some(),
            is_filtered: query.filters.is_some(),
            query,
            ..Default::default()
        }
    }

    fn get_select_string(&self) -> String {
        let mut select_string = String::from("SELECT ");
        let mut fields: Vec<String> = vec![];

        if self.query.select.is_some() {
            for select in self.query.select.as_ref().unwrap() {
                fields.push(format!("{}", select));
            }
        }

        if self.is_analytic {
            for agg in self.query.aggregates.as_ref().unwrap() {
                fields.push(format!("{}", agg));
            }
        }

        if fields.is_empty() {
            fields.push(String::from("*"));
        }

        select_string.push_str(&fields.join(", "));
        select_string
    }

    fn get_filter_string(&mut self, filter: Filter, index: i32) -> String {
        let mut filter_string = String::new();

        if index > 0 {
            if filter.glue.is_some() {
                filter_string.push_str(&format!("{} ", filter.glue.as_ref().unwrap()));
            } else {
                filter_string.push_str(&format!("{} ", Glue::And));
            }
        }

        filter_string.push_str(&format!("{} {} ", filter.column, filter.operator));

        if filter.operator == FilterOperator::IsNull || filter.operator == FilterOperator::IsNotNull
        {
            return filter_string.trim().to_string();
        }

        if filter.operator == FilterOperator::In || filter.operator == FilterOperator::NotIn {
            if let Some(values) = &filter.values {
                let placeholders = vec!["?"; values.len()];
                filter_string.push_str(&format!("({})", placeholders.join(", ")));
                for value in values {
                    self.params.push(SqliteValue(value.clone()));
                }
            } else {
                // TODO: throw error
            }
            return filter_string;
        }

        filter_string.push_str("?");
        match filter.operator {
            FilterOperator::Like | FilterOperator::NotLike => {
                self.params.push(SqliteValue(Value::String(format!(
                    "%{}%",
                    filter.value.unwrap().as_str().unwrap()
                ))));
            }
            FilterOperator::StartsWith => {
                self.params.push(SqliteValue(Value::String(format!(
                    "{}%",
                    filter.value.unwrap().as_str().unwrap()
                ))));
            }
            FilterOperator::EndsWith => {
                self.params.push(SqliteValue(Value::String(format!(
                    "%{}",
                    filter.value.unwrap().as_str().unwrap()
                ))));
            }
            _ => {
                self.params.push(SqliteValue(filter.value.unwrap().clone()));
            }
        }

        filter_string
    }

    fn get_where_string(&mut self) -> String {
        if !self.query.filters.is_some() {
            return String::from("");
        }
        let mut filters: Vec<String> = vec![];

        if self.query.filters.is_some() {
            let mut index = 0;
            for filter in self.query.filters.clone().unwrap() {
                filters.push(self.get_filter_string(filter, index));
                index += 1;
            }
        }
        let where_string = format!("WHERE {}", filters.join(", "));
        where_string
    }

    fn get_group_string(&self) -> String {
        if self.query.groups.is_some() {
            let mut groups: Vec<String> = vec![];
            for group in self.query.groups.clone().unwrap() {
                groups.push(format!("{}", group));
            }
            format!("GROUP BY {}", groups.join(", "))
        } else {
            String::new()
        }
    }

    fn get_order_string(&self) -> String {
        if self.query.orders.is_some() {
            let mut orders: Vec<String> = vec![];
            for order in self.query.orders.clone().unwrap() {
                orders.push(format!("{}", order));
            }
            format!("ORDER BY {}", orders.join(", "))
        } else {
            String::new()
        }
    }

    fn get_limit_string(&mut self) -> String {
        if let Some(limit) = self.query.limit {
            self.params.push(SqliteValue(serde_json::json!(limit)));
            "LIMIT ?".to_string()
        } else {
            String::new()
        }
    }

    fn get_offset_string(&mut self) -> String {
        if let Some(offset) = self.query.offset {
            self.params.push(SqliteValue(serde_json::json!(offset)));
            "OFFSET ?".to_string()
        } else {
            String::new()
        }
    }

    pub fn build_sqlite_query(&mut self) -> (String, Vec<SqliteValue>) {
        let mut query_parts = vec![self.get_select_string(), format!("FROM {}", self.table)];

        let where_query = self.get_where_string();
        if !where_query.is_empty() {
            query_parts.push(where_query);
        }

        let group_query = self.get_group_string();
        if !group_query.is_empty() {
            query_parts.push(group_query);
        }

        let order_query = self.get_order_string();
        if !order_query.is_empty() {
            query_parts.push(order_query);
        }

        let limit_query = self.get_limit_string();
        if !limit_query.is_empty() {
            query_parts.push(limit_query);
        }

        let offset_query = self.get_offset_string();
        if !offset_query.is_empty() {
            query_parts.push(offset_query);
        }

        let query = query_parts.join(" ");

        (query, self.params.clone())
    }

    pub fn fetch_all<T: rusqlite::types::FromSql>(&mut self, conn: &Connection) -> Result<Vec<T>> {
        let (sql, params) = self.build_sqlite_query();
        let mut stmt = conn.prepare(&sql)?;

        let params_slice: Vec<&dyn rusqlite::types::ToSql> = params
            .iter()
            .map(|v| v as &dyn rusqlite::types::ToSql)
            .collect();

        let rows = stmt.query_map(params_slice.as_slice(), |row| row.get(0))?;

        let mut results = Vec::new();
        for row in rows {
            results.push(row?);
        }

        Ok(results)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{Aggregate, AggregateOperation, HttpQuery, OrderDirection};

    #[test]
    fn test_simple_select_query() {
        let query = HttpQuery::builder()
            .select("name", None)
            .select("age", None)
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name, age FROM users");
        assert!(params.is_empty());
    }

    #[test]
    fn test_select_query_with_alias() {
        let query = HttpQuery::builder()
            .select("name", None)
            .select("age", Some("user_age"))
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name, age AS user_age FROM users");
        assert!(params.is_empty());
    }

    #[test]
    fn test_select_query_with_filter() {
        let query = HttpQuery::builder()
            .select("name", None)
            .filter(|f| {
                f.column("age")
                    .operator(FilterOperator::Gt)
                    .value(18)
                    .build()
            })
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name FROM users WHERE age > ?");
        assert_eq!(params.len(), 1);
        assert_eq!(params[0].0, serde_json::json!(18));
    }

    #[test]
    fn test_select_query_with_multiple_filters() {
        let query = HttpQuery::builder()
            .select("name", None)
            .filter(|f| {
                f.column("age")
                    .operator(FilterOperator::Gt)
                    .value(18)
                    .build()
            })
            .filter(|f| {
                f.column("city")
                    .operator(FilterOperator::Eq)
                    .value("New York")
                    .glue(Glue::And)
                    .build()
            })
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name FROM users WHERE age > ?, AND city = ?");
        assert_eq!(params.len(), 2);
        assert_eq!(params[0].0, serde_json::json!(18));
        assert_eq!(params[1].0, serde_json::json!("New York"));
    }

    #[test]
    fn test_select_query_with_order() {
        let query = HttpQuery::builder()
            .select("name", None)
            .order("age", OrderDirection::Desc)
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name FROM users ORDER BY age DESC");
        assert!(params.is_empty());
    }

    #[test]
    fn test_select_query_with_limit_and_offset() {
        let query = HttpQuery::builder()
            .select("name", None)
            .limit(10)
            .offset(20)
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name FROM users LIMIT ? OFFSET ?");
        assert_eq!(params.len(), 2);
        assert_eq!(params[0].0, serde_json::json!(10));
        assert_eq!(params[1].0, serde_json::json!(20));
    }

    #[test]
    fn test_select_query_with_aggregates() {
        let query = HttpQuery::builder()
            .aggregate(Aggregate {
                operation: AggregateOperation::Count,
                column: "id".to_string(),
                alias: Some("total_users".to_string()),
            })
            .aggregate(Aggregate {
                operation: AggregateOperation::Avg,
                column: "age".to_string(),
                alias: Some("average_age".to_string()),
            })
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(
            sql,
            "SELECT COUNT(id) AS total_users, AVG(age) AS average_age FROM users"
        );
        assert!(params.is_empty());
    }

    #[test]
    fn test_select_query_with_group_by() {
        let query = HttpQuery::builder()
            .select("department", None)
            .aggregate(Aggregate {
                operation: AggregateOperation::Count,
                column: "id".to_string(),
                alias: Some("employee_count".to_string()),
            })
            .group("department", None)
            .build();

        let mut builder = SqLiteQueryBuilder::new("employees".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(
            sql,
            "SELECT department, COUNT(id) AS employee_count FROM employees GROUP BY department"
        );
        assert!(params.is_empty());
    }

    #[test]
    fn test_complex_query() {
        let query = HttpQuery::builder()
            .select("name", None)
            .select("department", Some("dept"))
            .filter(|f| {
                f.column("age")
                    .operator(FilterOperator::Ge)
                    .value(18)
                    .build()
            })
            .filter(|f| {
                f.column("salary")
                    .operator(FilterOperator::Gt)
                    .value(50000)
                    .glue(Glue::And)
                    .build()
            })
            .order("name", OrderDirection::Asc)
            .aggregate(Aggregate {
                operation: AggregateOperation::Avg,
                column: "salary".to_string(),
                alias: Some("avg_salary".to_string()),
            })
            .group("department", None)
            .limit(100)
            .offset(0)
            .build();

        let mut builder = SqLiteQueryBuilder::new("employees".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name, department AS dept, AVG(salary) AS avg_salary FROM employees WHERE age >= ?, AND salary > ? GROUP BY department ORDER BY name ASC LIMIT ? OFFSET ?");
        assert_eq!(params.len(), 4);
        assert_eq!(params[0].0, serde_json::json!(18));
        assert_eq!(params[1].0, serde_json::json!(50000));
        assert_eq!(params[2].0, serde_json::json!(100));
        assert_eq!(params[3].0, serde_json::json!(0));
    }

    #[test]
    fn test_empty_query() {
        let query = HttpQuery::builder().build();
        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT * FROM users");
        assert!(params.is_empty());
    }

    #[test]
    fn test_query_with_in_operator() {
        let query = HttpQuery::builder()
            .select("name", None)
            .filter(|f| {
                f.column("status")
                    .operator(FilterOperator::In)
                    .values(vec!["active", "pending"])
                    .build()
            })
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name FROM users WHERE status IN (?, ?)");
        assert_eq!(params.len(), 2);
        assert_eq!(params[0].0, serde_json::json!("active"));
        assert_eq!(params[1].0, serde_json::json!("pending"));
    }

    #[test]
    fn test_query_with_like_operator() {
        let query = HttpQuery::builder()
            .select("name", None)
            .filter(|f| {
                f.column("email")
                    .operator(FilterOperator::Like)
                    .value("@example.com")
                    .build()
            })
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name FROM users WHERE email LIKE ?");
        assert_eq!(params.len(), 1);
        assert_eq!(params[0].0, serde_json::json!("%@example.com%"));
    }

    #[test]
    fn test_query_with_is_null_operator() {
        let query = HttpQuery::builder()
            .select("name", None)
            .filter(|f| {
                f.column("last_login")
                    .operator(FilterOperator::IsNull)
                    .build()
            })
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(sql, "SELECT name FROM users WHERE last_login IS NULL");
        assert!(params.is_empty());
    }

    #[test]
    fn test_query_with_multiple_aggregates() {
        let query = HttpQuery::builder()
            .aggregate(Aggregate {
                operation: AggregateOperation::Count,
                column: "*".to_string(),
                alias: Some("total_count".to_string()),
            })
            .aggregate(Aggregate {
                operation: AggregateOperation::Max,
                column: "salary".to_string(),
                alias: Some("max_salary".to_string()),
            })
            .aggregate(Aggregate {
                operation: AggregateOperation::Min,
                column: "age".to_string(),
                alias: Some("min_age".to_string()),
            })
            .build();

        let mut builder = SqLiteQueryBuilder::new("employees".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(
            sql,
            "SELECT COUNT(*) AS total_count, MAX(salary) AS max_salary, MIN(age) AS min_age FROM employees"
        );
        assert!(params.is_empty());
    }

    #[test]
    fn test_query_with_multiple_orders() {
        let query = HttpQuery::builder()
            .select("name", None)
            .select("age", None)
            .order("age", OrderDirection::Desc)
            .order("name", OrderDirection::Asc)
            .build();

        let mut builder = SqLiteQueryBuilder::new("users".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(
            sql,
            "SELECT name, age FROM users ORDER BY age DESC, name ASC"
        );
        assert!(params.is_empty());
    }

    #[test]
    fn test_query_with_complex_filter_combination() {
        let query = HttpQuery::builder()
            .select("name", None)
            .filter(|f| {
                f.column("age")
                    .operator(FilterOperator::Gt)
                    .value(18)
                    .build()
            })
            .filter(|f| {
                f.column("status")
                    .operator(FilterOperator::Eq)
                    .value("active")
                    .glue(Glue::And)
                    .build()
            })
            .filter(|f| {
                f.column("department")
                    .operator(FilterOperator::In)
                    .values(vec!["HR", "IT"])
                    .glue(Glue::Or)
                    .build()
            })
            .build();

        let mut builder = SqLiteQueryBuilder::new("employees".to_string(), query);
        let (sql, params) = builder.build_sqlite_query();

        assert_eq!(
            sql,
            "SELECT name FROM employees WHERE age > ?, AND status = ?, OR department IN (?, ?)"
        );
        assert_eq!(params.len(), 4);
        assert_eq!(params[0].0, serde_json::json!(18));
        assert_eq!(params[1].0, serde_json::json!("active"));
        assert_eq!(params[2].0, serde_json::json!("HR"));
        assert_eq!(params[3].0, serde_json::json!("IT"));
    }
}
