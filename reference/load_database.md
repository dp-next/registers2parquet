# Load a specific Parquet database into the R session

The loaded database will be converted into DuckDB so it can be used via
[`arrow::to_duckdb()`](https://arrow.apache.org/docs/r/reference/to_duckdb.html).

## Usage

``` r
load_database(name)
```

## Arguments

- name:

  Name of the database to load.

## Value

The database as an Arrow dataset.
