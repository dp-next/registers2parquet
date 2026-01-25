# Check that all paths are from the same register

Removes all non-letters from the file names in paths and checks that the
remaining characters are identical, i.e., the registers have the same
name.

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
