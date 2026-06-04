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
  # With a fake project ID and the temporary directory.
  # Uses `E` rather than `E:` because Windows has issues with a colon in the
  # path when using a temporary location.
  fastreg.project_rawdata_dir = fs::path_temp("E/rawdata/701020/"),
  fastreg.project_workdata_dir = fs::path_temp("E/workdata/701020/parquet-registers/")
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

## Setup

For the examples below, we’ve simulated SAS register data for two
registers, `bef` and `lmdb`:

``` r

rawdata_dir <- getOption("fastreg.project_rawdata_dir")
workdata_dir <- getOption("fastreg.project_workdata_dir")

registers_tbl <- fastreg::simulate_registers_with_paths(
  c("bef", "lmdb"),
  c("", "1999", "1999_1", "2020", "2021"),
  n = 1000,
  output_dir = rawdata_dir
)

sas_paths <- registers_tbl |>
  purrr::pwalk(fastreg::write_to_sas) |>
  dplyr::pull(output_path)
```

    #> E
    #> └── rawdata
    #>     └── 701020
    #>         ├── bef.sas7bdat
    #>         ├── bef1999.sas7bdat
    #>         ├── bef1999_1.sas7bdat
    #>         ├── bef2020.sas7bdat
    #>         ├── bef2021.sas7bdat
    #>         ├── lmdb.sas7bdat
    #>         ├── lmdb1999.sas7bdat
    #>         ├── lmdb1999_1.sas7bdat
    #>         ├── lmdb2020.sas7bdat
    #>         └── lmdb2021.sas7bdat

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

fastreg::convert(
  path = sas_paths[1],
  output_dir = workdata_dir
)
#> ✔ Converted 'bef.sas7bdat'
#> # A tibble: 1 × 5
#>   register_name input_path                        output_path row_count schema  
#>   <chr>         <fs::path>                        <fs::path>      <int> <list>  
#> 1 bef           …Pz/E/rawdata/701020/bef.sas7bdat …52.parquet      1000 <tibble>
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

    #> E
    #> ├── rawdata
    #> │   └── 701020
    #> │       ├── bef.sas7bdat
    #> │       ├── bef1999.sas7bdat
    #> │       ├── bef1999_1.sas7bdat
    #> │       ├── bef2020.sas7bdat
    #> │       ├── bef2021.sas7bdat
    #> │       ├── lmdb.sas7bdat
    #> │       ├── lmdb1999.sas7bdat
    #> │       ├── lmdb1999_1.sas7bdat
    #> │       ├── lmdb2020.sas7bdat
    #> │       └── lmdb2021.sas7bdat
    #> └── workdata
    #>     └── 701020
    #>         └── parquet-registers
    #>             └── bef
    #>                 └── year=__HIVE_DEFAULT_PARTITION__
    #>                     └── part-67b152.parquet

## Converting multiple registers in parallel

For many or large files, fastreg provides a
[targets](https://docs.ropensci.org/targets/) pipeline template that
parallelises conversion across CPU cores. By default it uses 10 workers,
but that can be adjusted in the pipeline in the `_targets.R` file to not
consume too many cores on a shared server.

To create the pipeline file, you can use the
[`use_template()`](https://dp-next.github.io/fastreg/reference/use_template.md)
function, which creates two files: a `_targets.R` pipeline and a
`conversion-log.qmd` Quarto document. When running the pipeline, the
conversion log is written to a PDF, named
`conversion-log-<timestamp>.pdf`, by default.

In this example, we’re outputting the template to a temporary directory.

``` r

pipeline_dir <- fs::path(workdata_dir, "conversion_pipeline")
fs::dir_create(pipeline_dir)

fastreg::use_template(path = pipeline_dir)
#> ✔ Created '/tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/conversion_pipeline/_targets.R'
#> ✔ Created '/tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/conversion_pipeline/_targets.R'
#> ℹ Edit the `config` section to set your paths.
```

Once the `_targets.R` file is created, open it and edit the `config`
section:

``` r

config <- list(
  sas_paths = fastreg::list_sas_files(rawdata_dir),
  output_dir = workdata_dir
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

## Listing available Parquet files and datasets

To list what Parquet files or datasets are available, use the
[`list_parquet_files()`](https://dp-next.github.io/fastreg/reference/list_parquet.md)
and
[`list_parquet_datasets()`](https://dp-next.github.io/fastreg/reference/list_parquet.md)
functions. These look in the `fastreg.project_workdata_dir` and
`fastreg.project_rawdata_dir` directories (set with
[`options()`](https://rdrr.io/r/base/options.html)) for any Parquet
files following a specific pattern.

You can use them interactively in the Console (which are shown in the
temporary directory when rendered on the website):

    Console

``` r

# For individual files
fastreg::list_parquet_files()
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/bef/year=1999/part-09e894.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/bef/year=1999/part-da06cb.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/bef/year=2020/part-788d3c.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/bef/year=2021/part-5eb797.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/bef/year=__HIVE_DEFAULT_PARTITION__/part-657315.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/bef/year=__HIVE_DEFAULT_PARTITION__/part-67b152.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/lmdb/year=1999/part-0e02df.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/lmdb/year=1999/part-a05ea7.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/lmdb/year=2020/part-81f21c.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/lmdb/year=2021/part-bb3a75.parquet
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/lmdb/year=__HIVE_DEFAULT_PARTITION__/part-72c905.parquet
# For datasets (registers with all years).
fastreg::list_parquet_datasets()
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/bef
#> /tmp/RtmpRAUZPz/E/workdata/701020/parquet-registers/lmdb
```

## Reading a Parquet register

The final function reads the converted Parquet register data into R,
returning a [DuckDB](https://duckdb.org/) table. Using a DuckDB table is
a powerful way to query and process large data without loading it all
into memory.

A quick way of reading a register is with the
[`read_register()`](https://dp-next.github.io/fastreg/reference/read_register.md)
function. This function looks for a given name of a register in either
the `fastreg.project_workdata_dir` or `fastreg.project_rawdata_dir`
directories (set with
[`options()`](https://rdrr.io/r/base/options.html)) and reads it as a
DuckDB table. You can also use the more specific
[`read_parquet_dataset()`](https://dp-next.github.io/fastreg/reference/read_parquet.md)
or
[`read_parquet_file()`](https://dp-next.github.io/fastreg/reference/read_parquet.md)
functions to read from a specific directory or file path.

``` r

bef <- fastreg::read_register("bef")
bef
#> # Source:   table<arrow_001> [?? x 5]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1015-azure:R 4.6.0/:memory:]
#>     koen pnr          foed_dato source_file                                 year
#>    <dbl> <chr>        <chr>     <chr>                                      <int>
#>  1     2 108684730664 19320112  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  2     1 982144017357 20070716  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  3     2 672580814975 19800805  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  4     2 439008110445 20090628  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  5     1 489714666740 20170225  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  6     2 155331797020 19730330  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  7     2 777951655096 19341022  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  8     2 167007504860 20010318  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  9     2 132473802596 19530901  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#> 10     2 876820784981 19310817  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#> # ℹ more rows
```

Or directly with
[`read_parquet_dataset()`](https://dp-next.github.io/fastreg/reference/read_parquet.md)
or
[`read_parquet_file()`](https://dp-next.github.io/fastreg/reference/read_parquet.md):

``` r

fastreg::list_parquet_datasets()[1] |>
  fastreg::read_parquet_dataset()
#> # Source:   table<arrow_002> [?? x 5]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1015-azure:R 4.6.0/:memory:]
#>     koen pnr          foed_dato source_file                                 year
#>    <dbl> <chr>        <chr>     <chr>                                      <int>
#>  1     2 108684730664 19320112  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  2     1 982144017357 20070716  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  3     2 672580814975 19800805  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  4     2 439008110445 20090628  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  5     1 489714666740 20170225  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  6     2 155331797020 19730330  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  7     2 777951655096 19341022  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  8     2 167007504860 20010318  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  9     2 132473802596 19530901  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#> 10     2 876820784981 19310817  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#> # ℹ more rows

# Or a single file
fastreg::list_parquet_files()[1] |>
  fastreg::read_parquet_file()
#> # Source:   table<arrow_003> [?? x 4]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1015-azure:R 4.6.0/:memory:]
#>     koen pnr          foed_dato source_file                                     
#>    <dbl> <chr>        <chr>     <chr>                                           
#>  1     2 108684730664 19320112  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#>  2     1 982144017357 20070716  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#>  3     2 672580814975 19800805  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#>  4     2 439008110445 20090628  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#>  5     1 489714666740 20170225  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#>  6     2 155331797020 19730330  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#>  7     2 777951655096 19341022  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#>  8     2 167007504860 20010318  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#>  9     2 132473802596 19530901  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#> 10     2 876820784981 19310817  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.sas7bd…
#> # ℹ more rows
```

The resulting DuckDB table can be filtered and transformed with `dplyr`.
For example, you can filter the data:

``` r

bef |>
  dplyr::filter(koen == 2) |>
  dplyr::compute()
#> # Source:   table<dbplyr_TDD6kZ7SxR> [?? x 5]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1015-azure:R 4.6.0/:memory:]
#>     koen pnr          foed_dato source_file                                 year
#>    <dbl> <chr>        <chr>     <chr>                                      <int>
#>  1     2 108684730664 19320112  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  2     2 672580814975 19800805  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  3     2 439008110445 20090628  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  4     2 155331797020 19730330  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  5     2 777951655096 19341022  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  6     2 167007504860 20010318  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  7     2 132473802596 19530901  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  8     2 876820784981 19310817  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#>  9     2 527918979807 19540605  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
#> 10     2 932479108596 19490511  /tmp/RtmpRAUZPz/E/rawdata/701020/bef1999.…  1999
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
