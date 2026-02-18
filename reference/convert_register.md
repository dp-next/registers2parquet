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
output directory, e.g.,
`output_dir/register_name/year=2020/part-ad5b.parquet` (the ending being
a UUID). If no year is found in the file name, the data is saved in a
`year=__HIVE_DEFAULT_PARTITION__` partition, which is the standard Hive
convention for missing partition values.

Two columns are added to the output: `source_file` (the original SAS
file path) and `year` (extracted from the file name, used as partition
key).

To be able to handle larger-than-memory SAS files, this function uses
[`convert_file()`](https://dp-next.github.io/fastreg/reference/convert_file.md)
internally and only converts one file at a time in chunks. As a result,
identical rows are not deduplicated.

## Usage

``` r
convert_register(path, output_dir, chunk_size = 10000000L)
```

## Arguments

- path:

  Paths to SAS files for one register. See
  [`list_sas_files()`](https://dp-next.github.io/fastreg/reference/list_sas_files.md).

- output_dir:

  Directory to save the Parquet output to. Must not include the register
  name as this will be extracted from `path` to create the register
  folder.

- chunk_size:

  Number of rows to read and convert at a time.

## Value

`output_dir`, invisibly.

## Examples

``` r
sas_file_directory <- fs::path_package("fastreg", "extdata")
convert_register(
  path = list_sas_files(sas_file_directory),
  output_dir = fs::path_temp("path/to/output/register/")
)
#> ✔ Converted test.sas7bdat
#> ✔ Successfully converted 1 file.
#> • Input: "test.sas7bdat"
#> • Output: Register files in /tmp/Rtmp8emD2d/path/to/output/register/test
```
