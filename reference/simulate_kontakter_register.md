# Create example kontakter registers

The data is simulated using
[`osdc::simulate_registers()`](https://steno-aarhus.github.io/osdc/reference/simulate_registers.html).
It's used in vignettes and tests.

## Usage

``` r
simulate_kontakter_register(n = 1000)
```

## Arguments

- n:

  Number of rows to simulate per simulated kontakter tibble.

## Value

A named list with four tibbles containing simulated kontakter registers.
