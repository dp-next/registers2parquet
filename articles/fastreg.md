# Getting started

fastreg aims to make working with Danish registers simpler and faster by
providing functionality to convert the SAS register files (`.sas7bdat`)
into [Parquet](https://parquet.apache.org/) and read the resulting
Parquet files. A *register* in this context refers to a collection of
related data files that belong to the same dataset, typically with
yearly snapshots (e.g., `bef2020.sas7bdat`,`bef2021.sas7bdat`).

## Why Parquet?

[Parquet](https://parquet.apache.org/) is a columnar storage file format
optimised for analytical workloads. Compared to
[SAS](https://fileinfo.com/extension/sas7bdat) files (and row-based
formats like CSV), Parquet offers:

- **Smaller file size**: Efficient compression significantly reduces
  disk space, especially for large datasets.
- **Faster queries**: The columnar layout speeds up analytical queries
  that only need a subset of columns.
- **Wide tool support**: Parquet is supported across data processing
  frameworks in [R](https://www.r-project.org/),
  [Python](https://www.python.org/), and beyond, making it easy to
  integrate into modern workflows.

## Setup

For the examples below, we’ve simulated SAS register data for two
registers, `bef` and `lmdb`:

Show setup code

``` r
library(fastreg)

sas_dir <- fs::path_temp("sas-dir")
fs::dir_create(sas_dir)

bef_list <- simulate_register(
  "bef",
  c("", "1999", "1999_1", "2020"),
  n = 1000
)

lmdb_list <- simulate_register(
  "lmdb",
  c("2020", "2021"),
  n = 1000
)

save_as_sas(
  c(bef_list, lmdb_list),
  sas_dir
)
```

    #> sas-dir
    #> ├── bef.sas7bdat
    #> ├── bef1999.sas7bdat
    #> ├── bef1999_1.sas7bdat
    #> ├── bef2020.sas7bdat
    #> ├── lmdb2020.sas7bdat
    #> └── lmdb2021.sas7bdat

## Converting a single file

Converting one file from SAS to Parquet in fastreg isn’t a simple change
of file extension. We make use of Parquet’s Hive partitioning to
organise the output by year, for easier querying and management. So the
output Parquet file is written to a subdirectory named after the year
extracted from the file name. Use the
[`convert_file()`](https://dp-next.github.io/fastreg/reference/convert_file.md)
function to convert a single SAS file to a year-partitioned Parquet
format:

``` r
sas_file <- fs::path(sas_dir, "bef2020.sas7bdat")
output_file_dir <- fs::path_temp("output-file-dir")

convert_file(
  path = sas_file,
  output_dir = output_file_dir
)
#> ✔ Converted 'bef2020.sas7bdat'
```

[`convert_file()`](https://dp-next.github.io/fastreg/reference/convert_file.md)
reads files in chunks (to be able to handle larger-than-memory data)
with a default of reading 1 million rows, extracts 4-digit years from
filenames for partitioning, and lowercases column names. See
[`?convert_file`](https://dp-next.github.io/fastreg/reference/convert_file.md)
for more details.

> **Note**
>
> When a SAS file contains more rows than the `chunk_size`, multiple
> Parquet files will be created from it. This doesn’t affect how the
> data is loaded with
> [`read_register()`](https://dp-next.github.io/fastreg/reference/read_register.md)
> (see [Reading a Parquet register](#reading-a-parquet-register) below),
> it only means you may see more Parquet files in the output than input
> SAS files.

Even though this only converts a single file, the output is partitioned
by the year extracted from the file name as seen below:

    #> output-file-dir
    #> └── bef
    #>     └── year=2020
    #>         └── part-2eaa37.parquet

## Converting a register

Use
[`list_sas_files()`](https://dp-next.github.io/fastreg/reference/list_sas_files.md)
to find SAS files in a directory (and any subdirectories), then use
[`convert_register()`](https://dp-next.github.io/fastreg/reference/convert_register.md)
to convert them.
[`convert_register()`](https://dp-next.github.io/fastreg/reference/convert_register.md)
expects files to be from the **same register** based on file names.

``` r
bef_sas_files <- list_sas_files(sas_dir) |>
  stringr::str_subset("bef")
bef_sas_files
#> /tmp/Rtmpdl4g0L/sas-dir/bef.sas7bdat
#> /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat
#> /tmp/Rtmpdl4g0L/sas-dir/bef1999.sas7bdat
#> /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat
```

``` r
output_register_dir <- fs::path_temp("output-register-dir")

convert_register(
  path = bef_sas_files,
  output_dir = output_register_dir
)
#> ✔ Converted 'bef.sas7bdat'
#> ✔ Converted 'bef1999_1.sas7bdat'
#> ✔ Converted 'bef1999.sas7bdat'
#> ✔ Converted 'bef2020.sas7bdat'
#> ✔ Successfully converted 4 files.
#> • Input: "bef.sas7bdat", "bef1999_1.sas7bdat", "bef1999.sas7bdat", and
#>   "bef2020.sas7bdat"
#> • Output: Register files in '/tmp/Rtmpdl4g0L/output-register-dir/bef'
```

[`convert_register()`](https://dp-next.github.io/fastreg/reference/convert_register.md)
uses
[`convert_file()`](https://dp-next.github.io/fastreg/reference/convert_file.md)
internally so the same chunking and partitioning behaviour applies. See
[`?convert_file`](https://dp-next.github.io/fastreg/reference/convert_file.md)
and
[`?convert_register`](https://dp-next.github.io/fastreg/reference/convert_register.md)
for more details. As a result, the output from
[`convert_register()`](https://dp-next.github.io/fastreg/reference/convert_register.md)
is also partitioned by year, extracted from file names:

    #> output-register-dir
    #> └── bef
    #>     ├── year=1999
    #>     │   ├── part-99b76a.parquet
    #>     │   └── part-9bdf65.parquet
    #>     ├── year=2020
    #>     │   └── part-50e9a0.parquet
    #>     └── year=__HIVE_DEFAULT_PARTITION__
    #>         └── part-3ae27c.parquet

The output is organised into a “bef” folder (register name extracted
from file names) with year-based subdirectories:

- The data from the two SAS files with “1999” in their file names are
  located in the subfolder “year=1999”
- The data from the SAS file from 2020 are located in the subfolder
  “year=2020”
- One SAS file didn’t have a year in its file name, `bef.sas7bdat`. The
  data from this file is placed in the “year=**HIVE_DEFAULT_PARTITION**”
  folder, the default for files without a year in their name.

## Converting multiple registers in parallel

For many or large files, fastreg provides a
[targets](https://docs.ropensci.org/targets/) pipeline template that
parallelises conversion across CPU cores. By default it uses 10 workers,
but that can be adjusted in the pipeline in the `_targets.R` file to not
consume too many cores on a shared server.

To create the pipeline file, you can use the
[`use_targets_template()`](https://dp-next.github.io/fastreg/reference/use_targets_template.md)
function. In this example, we’re outputting it to a temporary directory.

``` r
pipeline_dir <- fs::path_temp("pipeline-dir")
fs::dir_create(pipeline_dir)

use_targets_template(path = pipeline_dir)
#> ✔ Created '/tmp/Rtmpdl4g0L/pipeline-dir/_targets.R'
#> ℹ Edit the `config` section to set your paths.
```

Once the `_targets.R` file is created, open it and edit the `config`
section:

``` r
config <- list(
  sas_paths = list_sas_files(fs::path_temp("sas-dir")),
  output_dir = fs::path(pipeline_dir, "parquet-registers")
)
```

The `input_dir` is the directory that contains the SAS files (searched
recursively). This directory can contain different registers, rather
than just one as is expected in
[`convert_register()`](https://dp-next.github.io/fastreg/reference/convert_register.md).
The `output_dir` directory is where the Parquet files will be written
to.

After you’ve updated the `config` section, you can run the pipeline:

``` r
targets::tar_make()
```

The pipeline will find all SAS files from `input_dir` and convert each
file into a Parquet file, all done in parallel. Re-running `tar_make()`
only re-converts registers whose source files have changed or if the
pipeline itself has been edited.

## Reading a Parquet register

The final function reads the converted Parquet register data into R,
returning a [DuckDB](https://duckdb.org/) table. Using a DuckDB table is
a powerful way to query and process large data without loading it all
into memory.

You can pass a file path to read a single Parquet file:

``` r
file <- read_register(output_file_dir)
file
#> # Source:   table<arrow_001> [?? x 5]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.5.3/:memory:]
#>     koen pnr          foed_dato source_file                               year
#>    <dbl> <chr>        <chr>     <chr>                                    <int>
#>  1     2 108684730664 19320112  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#>  2     2 982144017357 20070716  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#>  3     1 672580814975 19800805  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#>  4     2 439008110445 20090628  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#>  5     2 489714666740 20170225  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#>  6     2 155331797020 19730330  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#>  7     2 777951655096 19341022  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#>  8     2 167007504860 20010318  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#>  9     2 132473802596 19530901  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#> 10     2 876820784981 19310817  /tmp/Rtmpdl4g0L/sas-dir/bef2020.sas7bdat  2020
#> # ℹ more rows
```

Or you can pass a directory to read the full partitioned register:

``` r
register <- read_register(output_register_dir)
register
#> # Source:   table<arrow_002> [?? x 5]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.5.3/:memory:]
#>     koen pnr          foed_dato source_file                                 year
#>    <dbl> <chr>        <chr>     <chr>                                      <int>
#>  1     2 108684730664 19320112  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#>  2     2 982144017357 20070716  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#>  3     1 672580814975 19800805  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#>  4     2 439008110445 20090628  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#>  5     2 489714666740 20170225  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#>  6     2 155331797020 19730330  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#>  7     2 777951655096 19341022  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#>  8     2 167007504860 20010318  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#>  9     2 132473802596 19530901  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#> 10     2 876820784981 19310817  /tmp/Rtmpdl4g0L/sas-dir/bef1999_1.sas7bdat  1999
#> # ℹ more rows
```

The resulting DuckDB table can be filtered and transformed with `dplyr`.
For example, `foed_dato` is stored as a character in the simulated data
(`"YYYYMMDD"`), so you can change it to a date (using
[`strptime()`](https://rdrr.io/r/base/strptime.html)) and then filter:

``` r
register |>
  dplyr::mutate(foed_dato = strptime(foed_dato, "%Y%m%d")) |>
  dplyr::filter(koen == 2 & foed_dato > "2000-01-01") |>
  dplyr::compute()
#> # Source:   table<dbplyr_TDD6kZ7SxR> [?? x 5]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.5.3/:memory:]
#>     koen pnr          foed_dato           source_file                       year
#>    <dbl> <chr>        <dttm>              <chr>                            <int>
#>  1     2 982144017357 2007-07-16 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#>  2     2 439008110445 2009-06-28 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#>  3     2 489714666740 2017-02-25 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#>  4     2 167007504860 2001-03-18 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#>  5     2 398008617406 2006-11-18 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#>  6     2 618760652262 2010-04-29 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#>  7     2 362243614874 2004-01-14 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#>  8     2 594290906244 2003-10-05 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#>  9     2 736038118634 2022-06-15 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#> 10     2 837052913533 2020-01-11 00:00:00 /tmp/Rtmpdl4g0L/sas-dir/bef1999…  1999
#> # ℹ more rows
```

After the query (filer and mutate), we execute it with
[`dplyr::compute()`](https://dplyr.tidyverse.org/reference/compute.html).
This save the result as a temporary table inside DuckDB, without loading
it into R memory.

Notice the `??` in the first line of the output. This shows us that the
total number of matching rows is not yet known because the data isn’t
loaded into memory.

> **Note**
>
> If you need to load the data into memory in R, you can use
> [`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html).
> However, for large registers this can take a long time, so only do
> this when it’s absolutely necessary and make sure to filter the data
> before collecting.
