# Convert register SAS file(s) and save to Parquet format

This function reads one or more SAS files for a given register, and
saves the data in Parquet format. It expects the input SAS files to come
from the same register, e.g., different years of the same register.

If multiple paths are given, the function looks for a year (the first
four consecutive digits) in the file names to use the year as partition,
see `vignettes("design")` for more information about the partitioning.
If a year is found, the data is saved partitioned by year in the output
directory, e.g., `path/to/register_name/year=2020/part-ad5b.parquet`
(the ending being an UUID). If no year is found in the file name, the
data is still partitioned with `year=NA`.

Because this function only converts one file at a time (in chunks) to be
able to handle larger-than-memory SAS files, duplicate rows across files
are not deduplicated.

## Usage

``` r
convert_to_parquet(paths, output_path, chunk_size = 10000000L)
```

## Arguments

- paths:

  A character vector with the absolute path to a SAS file or files for
  one register.

- output_path:

  A character scalar with the path to the directory to save the output
  Parquet file to. Should include the register name as the last part of
  the path. E.g., `path/to/register_name/`.

- chunk_size:

  An integer scalar indicating the number of rows to read at a time from
  the SAS files. Defaults to 10,000,000.

## Value

Returns a character scalar with the path to the created Parquet file(s)
(`output_path`), so it can be used in a
[targets](https://books.ropensci.org/targets/) pipeline.

## Examples

``` r
if (FALSE) { # \dontrun{
convert_to_parquet(
  list_sas_files("path/to/sas/files"),
  "output/path/to/register_name"
)
} # }
```
