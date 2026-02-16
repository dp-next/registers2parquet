# Convert a single register SAS file to Parquet

To be able to handle larger-than-memory files, the SAS file is converted
in chunks. It does not check for existing files in the output directory.
Existing data will not be overwritten, but might be duplicated if it
already exists in the directory, since files are saved with UUIDs in
their names.

## Usage

``` r
convert_file(path, output_dir, chunk_size = 10000000L)
```

## Arguments

- path:

  Path to a single SAS file.

- output_dir:

  Directory to save the Parquet output to. Must not include the register
  name as this will be extracted from `path` to create the register
  folder.

- chunk_size:

  Number of rows to read at a time.

## Value

`output_dir`, invisibly.

## Examples

``` r
sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
convert_file(
  path = sas_file,
  output_dir = fs::path_temp("path/to/output/file")
)
#> ✔ Converted test.sas7bdat
```
