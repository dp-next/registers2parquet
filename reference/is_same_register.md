# Check that all file paths are from the same register

Checks that all register names (file names without any non-letters) in
`path` are identical, i.e., the registers have the same name.

## Usage

``` r
is_same_register(path)
```

## Arguments

- path:

  A character vector of one or more paths to SAS register files.

## Value

A logical that's TRUE if all paths point to files from the same
register, based on the file names.
