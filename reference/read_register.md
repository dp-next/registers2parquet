# Read a Parquet register

If you want to read a partitioned Parquet register, provide the path to
the directory (e.g., `path/to/parquet/register/`). If you want to read a
single Parquet file, provide the path to the file (e.g.,
`path/to/parquet/register.parquet`).

## Usage

``` r
read_register(path)
```

## Arguments

- path:

  A character scalar with the path to the Parquet register.

## Value

The register as a DuckDB table.

## Examples

``` r
read_register(fs::path_package(
  "registers2parquet",
  "extdata",
  "test_register.parquet"
))
#> # Source:   table<arrow_001> [?? x 3]
#> # Database: DuckDB 1.4.3 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>     pnr  koen foed_dato 
#>   <int> <int> <date>    
#> 1     1     0 2000-01-01
#> 2     2     1 1995-05-05
#> 3     3     0 2010-10-10
#> 4     4     1 1980-12-12
#> 5     5     0 2005-03-03
```
