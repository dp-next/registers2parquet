# Write simulated data to a SAS file

A helper function that writes a data frame to a SAS file. It's used
mainly in fastreg's vignettes and tests. Pipe the output of
[`simulate_registers_with_paths()`](https://dp-next.github.io/fastreg/reference/simulate_registers_with_paths.md)
with [`purrr::pwalk()`](https://purrr.tidyverse.org/reference/pmap.html)
followed by this function to write each simulated dataset to a SAS file.

## Usage

``` r
write_to_sas(data, output_path)
```

## Arguments

- data:

  A tibble containing the simulated data.

- output_path:

  A string of the path to where the SAS file should be saved.

## Value

Invisibly gives the path to the saved SAS file.
