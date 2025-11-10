# List all the SAS register databases recursively in a folder

List all the SAS register databases recursively in a folder

## Usage

``` r
list_sas_files(dir)
```

## Arguments

- dir:

  Directory to list (recursively) all SAS database files (e.g. in
  `Grunddata/`).

## Value

A character vector of file paths.

## Examples

``` r
if (FALSE) { # \dontrun{
list_sas_files(path_grunddata_dir())
list_sas_files(path_eksterne_dir())
} # }
```
