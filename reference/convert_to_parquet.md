# Convert register SAS file(s) and save to Parquet format

This function reads one or more SAS files for a given register, and
saves the data in Parquet format. It expects the input SAS files to come
from the same register, e.g., different years of the same register.

The function looks for a year (the first four consecutive digits) in the
file names in `file_paths` to use the year as partition, see
`vignettes("design")` for more information about the partitioning.

If a year is found, the data is saved partitioned by year in the output
directory, e.g., `path/to/register_name/year=2020/part-ad5b.parquet`
(the ending being an UUID). If no year is found in the file name, the
data is still partitioned with `year=NA`.

Because this function only converts one file at a time (in chunks) to be
able to handle larger-than-memory SAS files, duplicate rows across files
are not deduplicated.

## Usage

``` r
convert_to_parquet(file_paths, output_dir, chunk_size = 10000000L)
```

## Arguments

- file_paths:

  A character vector with the absolute path to a SAS file or files for
  one register.

- output_dir:

  A character scalar with the path to the directory to save the output
  Parquet file to. Should include the register name as the last part of
  the path. E.g., `path/to/register_name/`.

- chunk_size:

  An integer scalar indicating the number of rows to read at a time from
  the SAS files. Defaults to 10,000,000.

## Value

Returns a character scalar with the path to the created Parquet file(s)
(`output_dir`), so it can be used in a
[targets](https://books.ropensci.org/targets/) pipeline.

## Examples

``` r
sas_file_directory <- fs::path_package("fastreg", "extdata")
convert_to_parquet(
  file_paths = list_sas_files(sas_file_directory),
  output_dir = fs::path_temp("path/to/register_name/")
)
#> ✔ Successfully converted "test.sas7bdat" and saved it in /tmp/RtmpjdGOoB/path/to/register_name.
#> /tmp/RtmpjdGOoB/path/to/register_name
```
