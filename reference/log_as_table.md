# Log chunk information as a table

Turns the log information returned by
[`convert()`](https://dp-next.github.io/fastreg/reference/convert.md)
into a pretty table, showing relative input/output paths and row counts.

## Usage

``` r
log_as_table(log)
```

## Arguments

- log:

  A tibble returned by
  [`convert()`](https://dp-next.github.io/fastreg/reference/convert.md),
  with columns `input_path`, `output_path`, and `row_count`.

## Value

A `knitr_kable` table.

## Examples

``` r
sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
conversion_log <- convert(sas_file, output_dir = fs::path_temp("output"))
#> ✔ Converted test.sas7bdat
log_as_table(conversion_log)
#> 
#> 
#> |input_path                                              |output_path                                                                                         | row_count|
#> |:-------------------------------------------------------|:---------------------------------------------------------------------------------------------------|---------:|
#> |../../../../_temp/Library/fastreg/extdata/test.sas7bdat |../../../../../../../tmp/RtmpATxCZ0/output/test/year=__HIVE_DEFAULT_PARTITION__/part-86f3a4.parquet |      1000|
```
