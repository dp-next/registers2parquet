# Read a single Parquet file or a partitioned dataset as DuckDB table

This is useful when the
[`read_register()`](https://dp-next.github.io/fastreg/reference/read_register.md)
incorrectly guesses or can't find the register.

## Usage

``` r
read_parquet_dataset(path)

read_parquet_file(path)
```

## Arguments

- path:

  Path to a directory with the Parquet files within or a path to a
  Parquet file.

## Value

A DuckDB table.

## Functions

- `read_parquet_dataset()`: Reads a Parquet partitioned directory.

- `read_parquet_file()`: Reads a single Parquet file.
