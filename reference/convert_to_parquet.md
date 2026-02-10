# Convert register SAS file(s) and save to Parquet format

This function reads one or more SAS files for a given register, and
saves the data in Parquet format. It expects the input SAS files to come
from the same register, e.g., different years of the same register. The
function checks that all files belong to the same register by comparing
the alphabetic characters in the file name(s).

The function looks for a year (1900-2099) in the file names in `path` to
use the year as partition, see
[`vignette("design")`](https://dp-next.github.io/fastreg/articles/design.md)
for more information about the partitioning.

If a year is found, the data is saved as a partition by year in the
output directory, e.g., `output_dir/year=2020/part-ad5b.parquet` (the
ending being a UUID). If no year is found in the file name, the data is
saved in a `year=__HIVE_DEFAULT_PARTITION__` partition, which is the
standard Hive convention for missing partition values.

Because this function only converts one file at a time (in chunks) to be
able to handle larger-than-memory SAS files, duplicate rows across files
are not deduplicated.

## Usage

``` r
convert_to_parquet(path, output_dir, chunk_size = 10000000L)
```

## Arguments

- path:

  A character vector of one or more paths to SAS file(s) for one
  register. See
  [`list_sas_files()`](https://dp-next.github.io/fastreg/reference/list_sas_files.md),
  which is a helper for this parameter.

- output_dir:

  A character scalar with the path to the directory to save the output
  Parquet file to. Should not include the register name as this will be
  extracted from `path`.

- chunk_size:

  An integer scalar indicating the number of rows to read at a time from
  the SAS files. Defaults to 10,000,000.

## Value

Returns a character scalar with the path to the created Parquet file(s)
(`output_dir`) invisibly, so it can be used in a
[targets](https://books.ropensci.org/targets/) pipeline.

## Examples

``` r
sas_file_directory <- fs::path_package("fastreg", "extdata")
convert_to_parquet(
  path = list_sas_files(sas_file_directory),
  output_dir = fs::path_temp("path/to/output/")
)
#> ✔ Successfully converted "test.sas7bdat" and saved it in /tmp/Rtmp4vbr7v/path/to/output.
```
