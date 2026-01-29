# Check that all paths are from the same register

Checks that all register names (file names without any non-letters) in
paths are identical, i.e., the registers have the same name.

## Usage

``` r
is_same_register(paths)
```

## Arguments

- paths:

  A character vector with paths to SAS registers.

## Value

A logical that's TRUE if all paths point to files from the same
register, based on the file names.
