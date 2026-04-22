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

  Path to a Parquet file or directory.

## Value

A DuckDB table.

## Examples

``` r
read_register(fs::path_package(
  "fastreg",
  "extdata",
  "test.parquet"
))
#> # Source:   table<arrow_001> [?? x 3]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1011-azure:R 4.5.3/:memory:]
#>     pnr  koen foed_dato 
#>   <int> <int> <date>    
#> 1     1     0 2000-01-01
#> 2     2     1 1995-05-05
#> 3     3     0 2010-10-10
#> 4     4     1 1980-12-12
#> 5     5     0 2005-03-03
```
