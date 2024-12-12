use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::fmt::Display;

#[derive(Deserialize)]
pub struct FIlterParam {
    pub filter: String,
}

pub struct Settings {
    pub db_path: String,
    pub db_file: String,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct HttpQuery {
    pub select: Option<Vec<Select>>,
    pub filters: Option<Vec<Filter>>,
    pub orders: Option<Vec<OrderBy>>,
    pub aggregates: Option<Vec<Aggregate>>,
    pub groups: Option<Vec<Group>>,
    pub limit: Option<i64>,
    pub offset: Option<i64>,
}

impl HttpQuery {
    pub fn builder() -> HttpQueryBuilder {
        HttpQueryBuilder::default()
    }
}

#[derive(Default)]
pub struct HttpQueryBuilder {
    select: Vec<Select>,
    filters: Vec<Filter>,
    orders: Vec<OrderBy>,
    aggregates: Vec<Aggregate>,
    groups: Vec<Group>,
    limit: Option<i64>,
    offset: Option<i64>,
}

impl HttpQueryBuilder {
    pub fn select<T: Into<String>>(mut self, column: T, alias: Option<T>) -> Self {
        self.select.push(Select {
            column: column.into(),
            alias: alias.map(Into::into),
        });
        self
    }

    pub fn filter<F>(mut self, filter: F) -> Self
    where
        F: FnOnce(FilterBuilder) -> Filter,
    {
        self.filters.push(filter(FilterBuilder::default()));
        self
    }

    pub fn order(mut self, column: impl Into<String>, direction: OrderDirection) -> Self {
        self.orders.push(OrderBy {
            column: column.into(),
            direction,
        });
        self
    }

    pub fn aggregate(mut self, aggregate: Aggregate) -> Self {
        self.aggregates.push(aggregate);
        self
    }

    pub fn group<T: Into<String>>(mut self, column: T, alias: Option<T>) -> Self {
        self.groups.push(Group {
            column: column.into(),
            alias: alias.map(Into::into),
        });
        self
    }

    pub fn limit(mut self, limit: i64) -> Self {
        self.limit = Some(limit);
        self
    }

    pub fn offset(mut self, offset: i64) -> Self {
        self.offset = Some(offset);
        self
    }

    pub fn build(self) -> HttpQuery {
        HttpQuery {
            select: Some(self.select).filter(|v| !v.is_empty()),
            filters: Some(self.filters).filter(|v| !v.is_empty()),
            orders: Some(self.orders).filter(|v| !v.is_empty()),
            aggregates: Some(self.aggregates).filter(|v| !v.is_empty()),
            groups: Some(self.groups).filter(|v| !v.is_empty()),
            limit: self.limit,
            offset: self.offset,
        }
    }
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Select {
    pub column: String,
    pub alias: Option<String>,
    // pub functions: Option<Vec<Function>>,
    // pub filters: Option<Vec<Filter>>,
    // pub table: Option<String>,
    // pub select: Option<Vec<Select>>,
}

impl Display for Select {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match &self.alias {
            Some(alias) => write!(f, "{} AS {}", self.column, alias),
            None => write!(f, "{}", self.column),
        }
    }
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Filter {
    pub column: String,
    pub operator: FilterOperator,
    pub value: Option<Value>,
    pub values: Option<Vec<Value>>,
    pub glue: Option<Glue>,
}

impl Filter {
    pub fn builder() -> FilterBuilder {
        FilterBuilder::default()
    }

    pub fn equal(column: impl Into<String>, value: impl Into<Value>, glue: Option<Glue>) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::Eq,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn not_equal(
        column: impl Into<String>,
        value: impl Into<Value>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::Ne,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn greater_than(
        column: impl Into<String>,
        value: impl Into<Value>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::Gt,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn less_than(
        column: impl Into<String>,
        value: impl Into<Value>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::Lt,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn greater_than_or_equal(
        column: impl Into<String>,
        value: impl Into<Value>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::Ge,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn less_than_or_equal(
        column: impl Into<String>,
        value: impl Into<Value>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::Le,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn like(column: impl Into<String>, value: impl Into<Value>, glue: Option<Glue>) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::Like,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn starts_with(
        column: impl Into<String>,
        value: impl Into<Value>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::StartsWith,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn ends_with(
        column: impl Into<String>,
        value: impl Into<Value>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::EndsWith,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn not_like(
        column: impl Into<String>,
        value: impl Into<Value>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::NotLike,
            value: Some(value.into()),
            values: None,
            glue: glue,
        }
    }

    pub fn in_list(
        column: impl Into<String>,
        values: Vec<impl Into<Value>>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::In,
            value: None,
            values: Some(values.into_iter().map(Into::into).collect()),
            glue: glue,
        }
    }

    pub fn not_in_list(
        column: impl Into<String>,
        values: Vec<impl Into<Value>>,
        glue: Option<Glue>,
    ) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::NotIn,
            value: None,
            values: Some(values.into_iter().map(Into::into).collect()),
            glue: glue,
        }
    }

    pub fn is_null(column: impl Into<String>, glue: Option<Glue>) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::IsNull,
            value: None,
            values: None,
            glue: glue,
        }
    }

    pub fn is_not_null(column: impl Into<String>, glue: Option<Glue>) -> Self {
        Filter {
            column: column.into(),
            operator: FilterOperator::IsNotNull,
            value: None,
            values: None,
            glue: glue,
        }
    }
}

#[derive(Default)]
pub struct FilterBuilder {
    column: String,
    operator: FilterOperator,
    value: Option<Value>,
    values: Option<Vec<Value>>,
    glue: Option<Glue>,
}

impl FilterBuilder {
    pub fn column(mut self, column: impl Into<String>) -> Self {
        self.column = column.into();
        self
    }

    pub fn operator(mut self, operator: FilterOperator) -> Self {
        self.operator = operator;
        self
    }

    pub fn value(mut self, value: impl Into<Value>) -> Self {
        self.value = Some(value.into());
        self
    }

    pub fn values(mut self, values: Vec<impl Into<Value>>) -> Self {
        self.values = Some(values.into_iter().map(Into::into).collect());
        self
    }

    pub fn glue(mut self, glue: Glue) -> Self {
        self.glue = Some(glue);
        self
    }

    pub fn build(self) -> Filter {
        Filter {
            column: self.column,
            operator: self.operator,
            value: self.value,
            values: self.values,
            glue: self.glue,
        }
    }
}

impl From<FilterBuilder> for Filter {
    fn from(builder: FilterBuilder) -> Self {
        builder.build()
    }
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum FilterOperator {
    #[default]
    Eq,
    Ne,
    Gt,
    Ng,
    Lt,
    Nl,
    Ge,
    Le,
    Like,
    StartsWith,
    EndsWith,
    NotLike,
    In,
    NotIn,
    IsNull,
    IsNotNull,
}

impl Display for FilterOperator {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            FilterOperator::Eq => write!(f, "="),
            FilterOperator::Ne => write!(f, "<>"),
            FilterOperator::Gt => write!(f, ">"),
            FilterOperator::Ng => write!(f, "!>"),
            FilterOperator::Lt => write!(f, "<"),
            FilterOperator::Nl => write!(f, "!<"),
            FilterOperator::Ge => write!(f, ">="),
            FilterOperator::Le => write!(f, "<="),
            FilterOperator::Like => write!(f, "LIKE"),
            FilterOperator::StartsWith => write!(f, "LIKE"),
            FilterOperator::EndsWith => write!(f, "LIKE"),
            FilterOperator::NotLike => write!(f, "NOT LIKE"),
            FilterOperator::In => write!(f, "IN"),
            FilterOperator::NotIn => write!(f, "NOT IN"),
            FilterOperator::IsNull => write!(f, "IS NULL"),
            FilterOperator::IsNotNull => write!(f, "IS NOT NULL"),
        }
    }
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Glue {
    #[default]
    And,
    Or,
    Not,
}

impl Display for Glue {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Glue::And => write!(f, "AND"),
            Glue::Or => write!(f, "OR"),
            Glue::Not => write!(f, "NOT"),
        }
    }
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct OrderBy {
    pub column: String,
    pub direction: OrderDirection,
}

impl Display for OrderBy {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self.direction {
            OrderDirection::Asc => write!(f, "{} ASC", self.column),
            OrderDirection::Desc => write!(f, "{} DESC", self.column),
        }
    }
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum OrderDirection {
    #[default]
    Asc,
    Desc,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Aggregate {
    pub operation: AggregateOperation,
    pub column: String,
    pub alias: Option<String>,
}

impl Display for Aggregate {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match &self.alias {
            Some(alias) => write!(f, "{}({}) AS {}", self.operation, self.column, alias),
            None => write!(f, "{}({})", self.operation, self.column),
        }
    }
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum AggregateOperation {
    #[default]
    Count,
    Sum,
    Avg,
    Min,
    Max,
}

impl Display for AggregateOperation {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AggregateOperation::Count => write!(f, "COUNT"),
            AggregateOperation::Sum => write!(f, "SUM"),
            AggregateOperation::Avg => write!(f, "AVG"),
            AggregateOperation::Min => write!(f, "MIN"),
            AggregateOperation::Max => write!(f, "MAX"),
        }
    }
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Group {
    pub column: String,
    pub alias: Option<String>,
}

impl Display for Group {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match &self.alias {
            Some(alias) => write!(f, "{} AS {}", self.column, alias),
            None => write!(f, "{}", self.column),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_empty_query() {
        let query = HttpQuery::builder().build();
        assert_eq!(query, HttpQuery::default());
    }

    #[test]
    fn test_select() {
        let query = HttpQuery::builder()
            .select("column1", None)
            .select("column2", Some("alias2"))
            .build();

        assert_eq!(
            query.select,
            Some(vec![
                Select {
                    column: "column1".to_string(),
                    alias: None
                },
                Select {
                    column: "column2".to_string(),
                    alias: Some("alias2".to_string())
                },
            ])
        );
    }

    #[test]
    fn test_filter() {
        let query = HttpQuery::builder()
            .filter(|f| {
                f.column("age")
                    .operator(FilterOperator::Gt)
                    .value(18)
                    .build()
            })
            .filter(|f| {
                f.column("name")
                    .operator(FilterOperator::Like)
                    .value("%John%")
                    .build()
            })
            .build();

        assert_eq!(
            query.filters,
            Some(vec![
                Filter {
                    column: "age".to_string(),
                    operator: FilterOperator::Gt,
                    value: Some(json!(18)),
                    values: None,
                    glue: None,
                },
                Filter {
                    column: "name".to_string(),
                    operator: FilterOperator::Like,
                    value: Some(json!("%John%")),
                    values: None,
                    glue: None,
                },
            ])
        );
    }

    #[test]
    fn test_order() {
        let query = HttpQuery::builder()
            .order("name", OrderDirection::Asc)
            .order("age", OrderDirection::Desc)
            .build();

        assert_eq!(
            query.orders,
            Some(vec![
                OrderBy {
                    column: "name".to_string(),
                    direction: OrderDirection::Asc
                },
                OrderBy {
                    column: "age".to_string(),
                    direction: OrderDirection::Desc
                },
            ])
        );
    }

    #[test]
    fn test_aggregate() {
        let query = HttpQuery::builder()
            .aggregate(Aggregate {
                operation: AggregateOperation::Count,
                column: "id".to_string(),
                alias: Some("total".to_string()),
            })
            .aggregate(Aggregate {
                operation: AggregateOperation::Avg,
                column: "salary".to_string(),
                alias: None,
            })
            .build();

        assert_eq!(
            query.aggregates,
            Some(vec![
                Aggregate {
                    operation: AggregateOperation::Count,
                    column: "id".to_string(),
                    alias: Some("total".to_string()),
                },
                Aggregate {
                    operation: AggregateOperation::Avg,
                    column: "salary".to_string(),
                    alias: None,
                },
            ])
        );
    }

    #[test]
    fn test_group() {
        let query = HttpQuery::builder()
            .group("department", None)
            .group("location", Some("office"))
            .build();

        assert_eq!(
            query.groups,
            Some(vec![
                Group {
                    column: "department".to_string(),
                    alias: None
                },
                Group {
                    column: "location".to_string(),
                    alias: Some("office".to_string())
                },
            ])
        );
    }

    #[test]
    fn test_limit_and_offset() {
        let query = HttpQuery::builder().limit(10).offset(20).build();

        assert_eq!(query.limit, Some(10));
        assert_eq!(query.offset, Some(20));
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

        assert!(query.select.is_some());
        assert!(query.filters.is_some());
        assert!(query.orders.is_some());
        assert!(query.aggregates.is_some());
        assert!(query.groups.is_some());
        assert_eq!(query.limit, Some(100));
        assert_eq!(query.offset, Some(0));
    }

    #[test]
    fn test_json_serialization() {
        let query = HttpQuery::builder()
            .select("name", None)
            .select("age", Some("user_age"))
            .filter(|f| {
                f.column("age")
                    .operator(FilterOperator::Gt)
                    .value(18)
                    .build()
            })
            .order("name", OrderDirection::Asc)
            .limit(10)
            .offset(0)
            .build();

        let json = serde_json::to_value(&query).unwrap();

        assert_eq!(
            json,
            json!({
                "select": [
                    {"column": "name", "alias": null},
                    {"column": "age", "alias": "user_age"}
                ],
                "filters": [
                    {
                        "column": "age",
                        "operator": "Gt",
                        "value": 18,
                        "values": null,
                        "glue": null
                    }
                ],
                "orders": [
                    {"column": "name", "direction": "Asc"}
                ],
                "aggregates": null,
                "groups": null,
                "limit": 10,
                "offset": 0
            })
        );
    }

    #[test]
    fn test_json_deserialization() {
        let json_str = r#"
        {
            "select": [
                {"column": "name", "alias": null},
                {"column": "age", "alias": "user_age"}
            ],
            "filters": [
                {
                    "column": "age",
                    "operator": "Gt",
                    "value": 18,
                    "values": null,
                    "glue": null
                }
            ],
            "orders": [
                {"column": "name", "direction": "Asc"}
            ],
            "limit": 10,
            "offset": 0
        }
        "#;

        let query: HttpQuery = serde_json::from_str(json_str).unwrap();

        assert_eq!(query.select.unwrap().len(), 2);
        assert_eq!(query.filters.unwrap().len(), 1);
        assert_eq!(query.orders.unwrap().len(), 1);
        assert_eq!(query.limit, Some(10));
        assert_eq!(query.offset, Some(0));
    }

    #[test]
    fn test_filter_with_into() {
        let query = HttpQuery::builder()
            .filter(|f| {
                f.column("age")
                    .operator(FilterOperator::Gt)
                    .value(18)
                    .into()
            })
            .filter(|f| {
                f.column("name")
                    .operator(FilterOperator::Like)
                    .value("%John%")
                    .into()
            })
            .build();

        assert_eq!(
            query.filters,
            Some(vec![
                Filter {
                    column: "age".to_string(),
                    operator: FilterOperator::Gt,
                    value: Some(json!(18)),
                    values: None,
                    glue: None,
                },
                Filter {
                    column: "name".to_string(),
                    operator: FilterOperator::Like,
                    value: Some(json!("%John%")),
                    values: None,
                    glue: None,
                },
            ])
        );
    }
}
