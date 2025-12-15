# Convert register SAS file(s) and save to Parquet format

This function reads one or more SAS files for a given register, removes
any duplicate rows, and saves the data in Parquet format. It expects the
input SAS files to come from the same register, e.g., different years of
the same register.

If multiple paths are given, the function looks for a year (4 digits) in
the file names to use the year as partition, see `vignettes("design")`
for more information about the partitioning. If a year is found, the
data is saved partitioned by year in the output directory, e.g.,
`path/to/register_name/year=2020/part-0.parquet`.

If no year can be found or only one path is given, the data is converted
without partitioning and saved as a Parquet file with the name specified
in the output path. E.g., if output_path is `path/to/register`, the
Parquet file will be saved as `path/to/register.parquet`.

If any duplicate rows are found, they are deduplicated before saving to
Parquet. If duplicate rows are found in multiple source files, the row
from the file that appears first in `path` is kept. Rows that are almost
identical across different files (e.g. different years) but that have a
difference in values are kept, as determining which is the correct value
requires domain knowledge.

## Usage

``` r
convert_to_parquet(path, output_path)
```

## Arguments

- path:

  A character vector with the absolute path to the register SAS file(s).

- output_path:

  A character scalar with the path to the directory to save the output
  Parquet file to. Should include the register name as the last part of
  the path. E.g., `path/to/register_name/`.

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
