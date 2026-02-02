# Check that all file paths are from the same register

Checks that all register names (file names without any non-letters) in
`file_paths` are identical, i.e., the registers have the same name.

## Usage

``` r
is_same_register(file_paths)
```

## Arguments

- file_paths:

  A character vector with paths to SAS register files.

## Value

A logical that's TRUE if all `file_paths` point to files from the same
register, based on the file names.
