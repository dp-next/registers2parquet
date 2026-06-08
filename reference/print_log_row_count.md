# Log chunk information as a table

Turns the log information returned by
[`convert()`](https://dp-next.github.io/fastreg/reference/convert.md)
into a pretty table, showing relative input/output paths and row counts.

## Usage

``` r
print_log_row_count(log)
```

## Arguments

- log:

  A tibble returned by
  [`convert()`](https://dp-next.github.io/fastreg/reference/convert.md),
  with columns `input_path`, `output_path`, and `row_count`.

## Value

`log` invisibly.

## Examples

``` r
sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
conversion_log <- convert(sas_file, output_dir = fs::path_temp("output"))
#> ✔ Converted test.sas7bdat
print_log_row_count(conversion_log)
#> 
#> 
#> |input_path                                              |output_path                                                                                         | row_count|
#> |:-------------------------------------------------------|:---------------------------------------------------------------------------------------------------|---------:|
#> |../../../../_temp/Library/fastreg/extdata/test.sas7bdat |../../../../../../../tmp/Rtmp4q5k0b/output/test/year=__HIVE_DEFAULT_PARTITION__/part-2dfaef.parquet |      1000|
```
