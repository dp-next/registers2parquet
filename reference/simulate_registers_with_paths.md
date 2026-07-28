# Simulate example registers along with output paths for SAS files

A helper function that simulates data using
[`osdc::simulate_registers()`](https://steno-aarhus.github.io/osdc/reference/simulate_registers.html).
It's used in vignettes and tests. It simulates data for one or more
registers and years.

## Usage

``` r
simulate_registers_with_paths(
  registers,
  years = "",
  n = 1000,
  output_dir = fs::path_temp("E/rawdata/701010/")
)
```

## Arguments

- registers:

  Name of one or more registers. Must be a register that
  [`osdc::simulate_registers()`](https://steno-aarhus.github.io/osdc/reference/simulate_registers.html)
  can simulate. See
  [`osdc::registers()`](https://steno-aarhus.github.io/osdc/reference/registers.html)
  for a list of available registers.

- years:

  One or more years to save the simulated data under. The year is used
  as a suffix in the file name. For example for register "bef" and year
  "1999", the file will be named `bef1999.sas7bdat`. Can also take no
  year.

- n:

  Number of rows of data to simulate per year.

- output_dir:

  The root directory appended to the created SAS paths. By default, the
  output_dir is a temp path that mimics the paths on DST,
  `E/rawdata/701010`. The default should technically be `E:` on Windows,
  but the default temporary directory on Windows for R doesn't allow
  using `:`, so we use `E` instead.

## Value

A nested tibble with a column `data` containing the simulated data and a
column `output_path` containing the path where the SAS file should be
saved to. Pipe to `purrr::pwalk(write_to_sas)` or
`purrr::pmap(write_to_sas)` to write each simulated dataset to a SAS
file.

## Examples

``` r
sim_regs <- simulate_registers_with_paths(
  registers = c("bef", "lmdb"),
  years = c("1999", "2000"),
  n = 10,
)
sim_regs
#> # A tibble: 4 × 2
#>   output_path                                        data             
#>   <fs::path>                                         <list>           
#> 1 /tmp/RtmpEFuhqQ/E/rawdata/701010/bef1999.sas7bdat  <tibble [10 × 3]>
#> 2 /tmp/RtmpEFuhqQ/E/rawdata/701010/bef2000.sas7bdat  <tibble [10 × 3]>
#> 3 /tmp/RtmpEFuhqQ/E/rawdata/701010/lmdb1999.sas7bdat <tibble [10 × 6]>
#> 4 /tmp/RtmpEFuhqQ/E/rawdata/701010/lmdb2000.sas7bdat <tibble [10 × 6]>

sim_regs |>
  purrr::pwalk(write_to_sas)
```
