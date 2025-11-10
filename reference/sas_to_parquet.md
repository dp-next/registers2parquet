# Read the raw SAS database file and save to a Parquet format

Parquet is a format for saving data in an efficient way and that allows
you to easily import it either with `arrow::read_arrow()` function or
with any SQL-based language. In this case, we recommend using DuckDB via
[`arrow::to_duckdb()`](https://arrow.apache.org/docs/r/reference/to_duckdb.html)
since it is a SQL language that is fast and is designed for data
analysis tasks.

## Usage

``` r
sas_to_parquet(input_path, output_path)
```

## Arguments

- input_path:

  The path to the raw SAS file.

- output_path:

  The path to save the Parquet file.

## Value

Returns a character vector of the created Parquet files (from
`output_path`), so as to be designed to work with targets.
