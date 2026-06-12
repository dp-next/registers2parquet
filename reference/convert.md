# Convert a single register SAS file to Parquet

To be able to handle larger-than-memory files, the SAS file is converted
in chunks. It does not check for existing files in the output directory.
Existing data will not be overwritten, but might be duplicated if it
already exists in the directory, since files are saved with UUIDs in
their names.

## Usage

``` r
convert(path, output_dir, chunk_size = 10000000L)
```

## Arguments

- path:

  Path to a single SAS file.

- output_dir:

  Directory to save the Parquet output to. Must not include the register
  name as this will be extracted from `path` to create the register
  folder.

- chunk_size:

  Number of rows to read and convert at a time.

## Value

A tibble with a conversion log about each written chunk.

## Examples

``` r
sas_file <- fs::path_package("fastreg", "extdata", "test.sas7bdat")
convert(
  path = sas_file,
  output_dir = fs::path_temp("path/to/output/file")
)
#> ✔ Converted test.sas7bdat
#> # A tibble: 1 × 5
#>   register_name input_path                        output_path row_count schema  
#>   <chr>         <fs::path>                        <fs::path>      <int> <list>  
#> 1 test          …ry/fastreg/extdata/test.sas7bdat …d5.parquet      1000 <tibble>
```
