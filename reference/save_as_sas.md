# Save a list of data frames as SAS files

Writes each element of a named list as a SAS file to the given
directory. The file names are derived from the list names.

## Usage

``` r
save_as_sas(data_list, path)
```

## Arguments

- data_list:

  A named list of data frames.

- path:

  Directory to save the SAS files to.

## Value

`path`, invisibly.

## Examples

``` r
save_as_sas(data_list = simulate_register("kontakter", "2020"), path = fs::path_temp())
```
