# Simulate an example register

This is a helper function that simulates data using
[`osdc::simulate_registers()`](https://steno-aarhus.github.io/osdc/reference/simulate_registers.html).
It's used in vignettes and tests.

## Usage

``` r
simulate_register(register, year = "", n = 1000)
```

## Arguments

- register:

  Name of the register. Must be accepted by
  [`osdc::simulate_registers()`](https://steno-aarhus.github.io/osdc/reference/simulate_registers.html).

- year:

  Year suffixes for list element names (e.g., `"2020"`, `"1999_1"`, or
  `""` for no suffix).

- n:

  Number of rows per year.

## Value

A named list of tibbles following the naming scheme `{register}{year}`
or just `{register}` when year = "".

## Examples

``` r
simulate_register(register = "bef", year = c("1999", "2000"))
#> $bef1999
#> # A tibble: 1,000 × 3
#>     koen pnr          foed_dato
#>    <int> <chr>        <chr>    
#>  1     2 108684730664 19320112 
#>  2     2 982144017357 20070716 
#>  3     1 672580814975 19800805 
#>  4     2 439008110445 20090628 
#>  5     2 489714666740 20170225 
#>  6     2 155331797020 19730330 
#>  7     2 777951655096 19341022 
#>  8     2 167007504860 20010318 
#>  9     2 132473802596 19530901 
#> 10     2 876820784981 19310817 
#> # ℹ 990 more rows
#> 
#> $bef2000
#> # A tibble: 1,000 × 3
#>     koen pnr          foed_dato
#>    <int> <chr>        <chr>    
#>  1     2 108684730664 19320112 
#>  2     2 982144017357 20070716 
#>  3     1 672580814975 19800805 
#>  4     2 439008110445 20090628 
#>  5     2 489714666740 20170225 
#>  6     2 155331797020 19730330 
#>  7     2 777951655096 19341022 
#>  8     2 167007504860 20010318 
#>  9     2 132473802596 19530901 
#> 10     2 876820784981 19310817 
#> # ℹ 990 more rows
#> 
```
