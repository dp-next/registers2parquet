# List SAS files in a directory

Lists all SAS register files (with the extension `.sas7bdat`
case-insensitively) in the specified directory and its subdirectories.

## Usage

``` r
list_sas_files(path)
```

## Arguments

- path:

  Directory to search.

## Value

The path(s) to the found SAS files.

## Examples

``` r
list_sas_files(fs::path_package("fastreg", "extdata"))
#> /home/runner/work/_temp/Library/fastreg/extdata/test.sas7bdat
```
