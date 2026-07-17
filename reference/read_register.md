# Read a Parquet register

This function uses the options `fastreg.project_rawdata_dir` and
`fastreg.project_workdata_dir` when set in
[`options()`](https://rdrr.io/r/base/options.html) or will try to guess
the path by using the project ID and the base directories
`E:/rawdata/<project-id>/` and `E:/workdata/<project-id>/`. It only
reads Parquet datasets (those that are partitioned with the pattern
`year=`). If this function doesn't work, use
[`read_parquet_dataset()`](https://dp-next.github.io/fastreg/reference/read_parquet.md)
or
[`read_parquet_file()`](https://dp-next.github.io/fastreg/reference/read_parquet.md)
instead.

## Usage

``` r
read_register(name)
```

## Arguments

- name:

  Name of the Parquet dataset (i.e, the register name). See a list of
  available datasets with
  [`list_parquet_datasets()`](https://dp-next.github.io/fastreg/reference/list_parquet.md).

## Value

A DuckDB table.
