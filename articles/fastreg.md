# Getting started

fastreg aims to make working with Danish registers simpler and faster by
providing functionality to convert the SAS register files (`.sas7bdat`)
into [Parquet](https://parquet.apache.org/) and read the resulting
Parquet files. A *register* in this context refers to a collection of
related data files that belong to the same dataset, typically with
yearly snapshots (e.g., `bef2020.sas7bdat`,`bef2021.sas7bdat`).

> **Note**
>
> We use package prefixes (`fastreg::`) throughout the documentation
> rather than [`library()`](https://rdrr.io/r/base/library.html) calls,
> to make the package origin of each function explicit and avoid naming
> conflicts.

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
sas_dir <- fs::path_temp("sas-dir")
fs::dir_create(sas_dir)

bef_list <- fastreg::simulate_register(
  "bef",
  c("", "1999", "1999_1", "2020"),
  n = 1000
) |>
  # Randomly (re)generate koen, so we don't rely on any potential future
  # changes to the simulated data from osdc.
  purrr::map(\(x) {
    x |> dplyr::mutate("koen" = sample(c(1, 2), 1000, replace = TRUE))
  })

lmdb_list <- fastreg::simulate_register(
  "lmdb",
  c("2020", "2021"),
  n = 1000
)

fastreg::save_as_sas(
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

## Settings to correct paths

Many of fastreg’s functions depend on the locations of the original SAS
files and the eventual Parquet files including the conversion, writing,
and reading functions. Through
[`options()`](https://rdrr.io/r/base/options.html) you can set these
paths in two settings: `fastreg.project_rawdata_dir` and
`fastreg.project_workdata_dir`. You can set these
[`options()`](https://rdrr.io/r/base/options.html) at the top of your R
script or Quarto document, in your R Project’s `.Rprofile`, or in your
user-level `.Rprofile`. To add to the file, at the top of an R script,
write (using a temporary directory here for these examples):

``` r
options(
  # With a fake project ID.
  fastreg.project_rawdata_dir = fs::path_temp("rawdata/701010/"),
  fastreg.project_workdata_dir = fs::path_temp("workdata/701010/")
)
```

If you want to set those exact same options in the R Project’s
`.Rprofile`, run the following line in your Console to open up the
`.Rprofile` file for the project:

    Console

``` r
usethis::edit_r_profile("project")
```

You can then add the same
[`options()`](https://rdrr.io/r/base/options.html) as shown in the R
script example above to that file and save it. The next time you open
the project, those options will be set.

If you want to set these options for all of your R projects and
sessions, you can add them globally in your user-level `.Rprofile`. To
open the `.Rprofile`, run:

    Console

``` r
usethis::edit_r_profile("user")
```

## Converting a single file

Converting one file from SAS to Parquet in fastreg isn’t a simple change
of file extension. We make use of Parquet’s Hive partitioning to
organise the output by year, for easier querying and management. So the
output Parquet file is written to a subdirectory named after the year
extracted from the file name. Use the
[`convert()`](https://dp-next.github.io/fastreg/reference/convert.md)
function to convert a single SAS file to a year-partitioned Parquet
format:

``` r
sas_file <- fs::path(sas_dir, "bef2020.sas7bdat")
output_file_dir <- fs::path_temp("output-file-dir")

fastreg::convert(
  path = sas_file,
  output_dir = output_file_dir
)
#> ✔ Converted 'bef2020.sas7bdat'
```

[`convert()`](https://dp-next.github.io/fastreg/reference/convert.md)
reads files in chunks (to be able to handle larger-than-memory data)
with a default of reading 1 million rows, extracts 4-digit years from
filenames for partitioning, and lowercases column names. See
[`?convert`](https://dp-next.github.io/fastreg/reference/convert.md) for
more details.

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
    #>         └── part-e07985.parquet

## Converting multiple registers in parallel

For many or large files, fastreg provides a
[targets](https://docs.ropensci.org/targets/) pipeline template that
parallelises conversion across CPU cores. By default it uses 10 workers,
but that can be adjusted in the pipeline in the `_targets.R` file to not
consume too many cores on a shared server.

To create the pipeline file, you can use the
[`use_template()`](https://dp-next.github.io/fastreg/reference/use_template.md)
function. In this example, we’re outputting it to a temporary directory.

``` r
pipeline_dir <- fs::path_temp("pipeline-dir")
fs::dir_create(pipeline_dir)

fastreg::use_template(path = pipeline_dir)
#> ✔ Created '/tmp/RtmpyaqGzr/pipeline-dir/_targets.R'
#> ℹ Edit the `config` section to set your paths.
```

Once the `_targets.R` file is created, open it and edit the `config`
section:

``` r
config <- list(
  sas_paths = fastreg::list_sas_files(fs::path_temp("sas-dir")),
  output_dir = fs::path(pipeline_dir, "parquet-registers")
)
```

The `input_dir` is the directory that contains the SAS files (searched
recursively). This directory can contain different registers. The
`output_dir` directory is where the Parquet files will be written to.

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

You can pass a directory to read a full partitioned register or a file
path to read a single Parquet file:

``` r
file <- fastreg::read_register(output_file_dir)
file
#> # Source:   table<arrow_001> [?? x 5]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.5.3/:memory:]
#>     koen pnr          foed_dato source_file                               year
#>    <dbl> <chr>        <chr>     <chr>                                    <int>
#>  1     1 108684730664 19320112  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  2     1 982144017357 20070716  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  3     2 672580814975 19800805  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  4     1 439008110445 20090628  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  5     1 489714666740 20170225  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  6     2 155331797020 19730330  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  7     1 777951655096 19341022  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  8     2 167007504860 20010318  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  9     2 132473802596 19530901  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#> 10     2 876820784981 19310817  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#> # ℹ more rows
```

The resulting DuckDB table can be filtered and transformed with `dplyr`.
For example, you can filter the data:

``` r
file |>
  dplyr::filter(koen == 2) |>
  dplyr::compute()
#> # Source:   table<dbplyr_TDD6kZ7SxR> [?? x 5]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.5.3/:memory:]
#>     koen pnr          foed_dato source_file                               year
#>    <dbl> <chr>        <chr>     <chr>                                    <int>
#>  1     2 672580814975 19800805  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  2     2 155331797020 19730330  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  3     2 167007504860 20010318  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  4     2 132473802596 19530901  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  5     2 876820784981 19310817  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  6     2 527918979807 19540605  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  7     2 932479108596 19490511  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  8     2 983125164454 19011009  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#>  9     2 702393367207 19600605  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
#> 10     2 398008617406 20061118  /tmp/RtmpyaqGzr/sas-dir/bef2020.sas7bdat  2020
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
