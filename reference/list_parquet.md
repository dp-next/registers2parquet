# List Parquet datasets or files in a project

Only lists Parquet files that end in `part-*.parquet`. For datasets, it
will only look for Parquet files with a `year=YYYY` in its path. This
function will search the whole system for the project ID, so it might be
slow sometimes.

## Usage

``` r
list_parquet_datasets()

list_parquet_files()
```

## Value

The path(s) to the Parquet datasets (as directories) or files.

## Functions

- `list_parquet_datasets()`: List all Parquet (Hive partitioned by year)
  datasets.

- `list_parquet_files()`: List all Parquet files within a project.
