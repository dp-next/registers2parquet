# Convert the path to represent a Parquet Partition in another directory

Converts the file path to the pattern:
`{output_dir}/{file_name}/part-0.parquet`, since this is the style used
to tell Parquet the file is part of a partition. This includes
converting to a year partition as
`{output_dir}/{file_name}/style={year}/part-0.parquet`.

## Usage

``` r
path_alter_to_output_parquet_partition(path, output_dir)
```

## Arguments

- path:

  A file path.

- output_dir:

  New directory the file should be in.

## Value

A character vector.

## Examples

``` r
fs::path_temp("database.sas7bdat") |>
  path_alter_to_output_parquet_partition(fs::path_temp("new-dir"))
#> /tmp/RtmpmpeFRb/new-dir/database/part-0.parquet
fs::file_temp(pattern = "database2020-", ext = ".sas7bdat") |>
  path_alter_to_output_parquet_partition(fs::path_temp("new-dir"))
#> /tmp/RtmpmpeFRb/new-dir/database/year=2020/part-0.parquet
```
