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

## Configuring paths

Many of fastreg’s functions depend on the locations of the original SAS
files and the eventual Parquet files, including the conversion, writing,
and reading functions. You can configure these paths via two options:
`fastreg.project_rawdata_dir` and `fastreg.project_workdata_dir`. You
can set these [`options()`](https://rdrr.io/r/base/options.html) at the
top of your R script or Quarto document, in your R Project’s
`.Rprofile`, or in your user-level `.Rprofile`. To add to the file, at
the top of an R script, write (using a temporary directory here for
these examples):

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
#> 1 bef           …wk/E/rawdata/701020/bef.sas7bdat …e1.parquet      1000 <tibble>
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
> you may see multiple Parquet files per source SAS file.

> **Warning**
>
> If you’re handling very large SAS files, please refer to the [When SAS
> files become too big](#sec-large-sas-files) section below.

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
    #>                     └── part-280ae1.parquet

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
#> ✔ Created '/tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/conversion_pipeline/_targets.R'
#> ✔ Created '/tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/conversion_pipeline/_targets.R'
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

The `sas_paths` is a vector of paths to the SAS files to convert, found
recursively via
[`list_sas_files()`](https://dp-next.github.io/fastreg/reference/list_sas_files.md).
This can span different registers. The `output_dir` is where the Parquet
files will be written.

After you’ve updated the `config` section, you can run the pipeline:

``` r

targets::tar_make()
```

The pipeline will find all SAS files from `input_dir` and convert each
file into a Parquet file, all done in parallel. Re-running `tar_make()`
only re-converts registers whose source files have changed or if the
pipeline itself has been edited.

> **Warning**
>
> If you’re handling very large SAS files, please refer to the [When SAS
> files become too big](#sec-large-sas-files) section below.

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
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/bef/year=1999/part-59e6a7.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/bef/year=2020/part-3085da.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/bef/year=2021/part-7ba0d3.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/bef/year=__HIVE_DEFAULT_PARTITION__/part-280ae1.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/bef/year=__HIVE_DEFAULT_PARTITION__/part-bfd86e.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/bef_/year=1999/part-8cdfc4.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/lmdb/year=1999/part-f99040.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/lmdb/year=2020/part-321ae3.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/lmdb/year=2021/part-c2365c.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/lmdb/year=__HIVE_DEFAULT_PARTITION__/part-19f7f1.parquet
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/lmdb_/year=1999/part-df218c.parquet
# For datasets (registers with all years).
fastreg::list_parquet_datasets()
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/bef
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/bef_
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/lmdb
#> /tmp/RtmpSdtDwk/E/workdata/701020/parquet-registers/lmdb_
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
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.4 [unknown@Linux 6.17.0-1018-azure:R 4.6.1/:memory:]
#>     koen pnr          foed_dato  source_file                                year
#>    <dbl> <chr>        <date>     <chr>                                     <int>
#>  1     1 108684730664 1932-01-12 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  2     1 982144017357 2007-07-16 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  3     2 672580814975 1980-08-05 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  4     2 439008110445 2009-06-28 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  5     1 489714666740 2017-02-25 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  6     2 155331797020 1973-03-30 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  7     2 777951655096 1934-10-22 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  8     2 167007504860 2001-03-18 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  9     1 132473802596 1953-09-01 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#> 10     2 876820784981 1931-08-17 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#> # ℹ more rows
```

Or directly with
[`read_parquet_dataset()`](https://dp-next.github.io/fastreg/reference/read_parquet.md)
or
[`read_parquet_file()`](https://dp-next.github.io/fastreg/reference/read_parquet.md):

``` r

fastreg::list_parquet_datasets()[1] |>
  fastreg::read_parquet_dataset()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.4 [unknown@Linux 6.17.0-1018-azure:R 4.6.1/:memory:]
#>     koen pnr          foed_dato  source_file                                year
#>    <dbl> <chr>        <date>     <chr>                                     <int>
#>  1     1 108684730664 1932-01-12 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  2     1 982144017357 2007-07-16 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  3     2 672580814975 1980-08-05 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  4     2 439008110445 2009-06-28 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  5     1 489714666740 2017-02-25 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  6     2 155331797020 1973-03-30 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  7     2 777951655096 1934-10-22 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  8     2 167007504860 2001-03-18 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  9     1 132473802596 1953-09-01 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#> 10     2 876820784981 1931-08-17 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#> # ℹ more rows

# Or a single file
fastreg::list_parquet_files()[1] |>
  fastreg::read_parquet_file()
#> # A query:  ?? x 4
#> # Database: DuckDB 1.5.4 [unknown@Linux 6.17.0-1018-azure:R 4.6.1/:memory:]
#>     koen pnr          foed_dato  source_file                                    
#>    <dbl> <chr>        <date>     <chr>                                          
#>  1     1 108684730664 1932-01-12 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#>  2     1 982144017357 2007-07-16 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#>  3     2 672580814975 1980-08-05 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#>  4     2 439008110445 2009-06-28 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#>  5     1 489714666740 2017-02-25 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#>  6     2 155331797020 1973-03-30 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#>  7     2 777951655096 1934-10-22 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#>  8     2 167007504860 2001-03-18 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#>  9     1 132473802596 1953-09-01 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#> 10     2 876820784981 1931-08-17 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999.sas7b…
#> # ℹ more rows
```

The resulting DuckDB table can be filtered and transformed with `dplyr`.
For example, you can filter the data:

``` r

bef |>
  dplyr::filter(koen == 2) |>
  dplyr::compute()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.4 [unknown@Linux 6.17.0-1018-azure:R 4.6.1/:memory:]
#>     koen pnr          foed_dato  source_file                                year
#>    <dbl> <chr>        <date>     <chr>                                     <int>
#>  1     2 672580814975 1980-08-05 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  2     2 439008110445 2009-06-28 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  3     2 155331797020 1973-03-30 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  4     2 777951655096 1934-10-22 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  5     2 167007504860 2001-03-18 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  6     2 876820784981 1931-08-17 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  7     2 983125164454 1901-10-09 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  8     2 702393367207 1960-06-05 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#>  9     2 398008617406 2006-11-18 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#> 10     2 829139228682 1976-04-20 /tmp/RtmpSdtDwk/E/rawdata/701020/bef1999…  1999
#> # ℹ more rows
```

After the query, we execute it with
[`dplyr::compute()`](https://dplyr.tidyverse.org/reference/compute.html).
This saves the result as a temporary table inside DuckDB, without
loading it into R memory.

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

## When SAS files become too big (\> 2,147,483,647 rows)

When developing this package, we encountered an issue on Windows where
[`haven::read_sas()`](https://haven.tidyverse.org/reference/read_sas.html)
fails when the `skip` parameter is set to more than 2,147,483,647 (the
32-bit integer limit, 2^31 − 1). Instead of reading the expected rows,
the function reads the first part of the SAS file again.

fastreg currently handles this by stopping the conversion after
2,147,483,647 rows and returning a warning. This means that **fastreg
does not convert the rest of the data in that file**.

You can get around this by handling the original SAS file in two ways:

1.  Split the large SAS file into two. Name them something like
    `<register_name>01.sas7bdat`,`<register_name>02.sas7bdat`, etc.
    (avoid extra `_` as they are kept as a part of the name of the
    partitioned Parquet register). If you use the `_targets.R` pipeline,
    add the paths of these files in the `sas_paths` (see section on
    converting multiple registers in parallel above).

2.  Convert the large SAS file to another format, e.g., `.csv`, and
    convert it separately, as shown in the code block below. You can
    either keep this as a separate script or add it to your targets
    pipeline.

``` r

large_csv_path <- fs::path("path/to/large_register2020.csv")
output_dir <- fs::path("path/to/output/dir")

arrow::open_dataset(large_csv_path, format = "csv") |>
  dplyr::rename_with(tolower) |>
  arrow::write_dataset(
    path = fs::path(output_dir, "large_register", "year=2020"),
    format = "parquet"
  )
```

To follow the default Parquet partitioning name, use
`"year=__HIVE_DEFAULT_PARTIION__"` if the file doesn’t contain a year in
the name.
