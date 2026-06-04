# Print log schema comparison

Prints the log schema information in a section that compares the schemas
within one register. Finds the most common schema and if there's
differences between schemas, it prints these differences.

## Usage

``` r
print_log_schema(register_log)
```

## Arguments

- register_log:

  A tibble returned by
  [`convert()`](https://dp-next.github.io/fastreg/reference/convert.md),
  filtered to only contain rows from a single register.

## Value

register_log invisibly.

## Examples

``` r
sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
log <- convert(sas_file, output_dir = fs::path_temp("output"))
#> ✔ Converted test.sas7bdat
print_log_schema(log)
#> All files in this register share the same schema.
#> 
#> |column_name       |data_type |
#> |:-----------------|:---------|
#> |cpr               |character |
#> |dw_ek_kontakt     |character |
#> |dato_start        |character |
#> |hovedspeciale_ans |character |
#> |source_file       |character |
#> 
#>  
```
