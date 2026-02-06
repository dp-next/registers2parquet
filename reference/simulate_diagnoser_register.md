# Create example diagnoser registers

The data is simulated using
[`osdc::simulate_registers()`](https://steno-aarhus.github.io/osdc/reference/simulate_registers.html).
It's used in vignettes and tests.

## Usage

``` r
simulate_diagnoser_register(n = 1000)
```

## Arguments

- n:

  Number of rows to simulate per simulated diagnoser tibble.

## Value

A named list with two tibbles containing simulated diagnoser registers.
