# Getting started

One of the main purposes of fastreg is to ease the conversion of SAS
register files (`.sas7bdat`) into
[Parquet](https://parquet.apache.org/). A *register* in this context
refers to a collection of related data files that belong to the same
dataset, typically with yearly snapshots (e.g., `bef2020.sas7bdat`,
`bef2021.sas7bdat`).

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
  c("", "1999_1", "1999_2", "2020"),
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
    #> ├── bef1999_1.sas7bdat
    #> ├── bef1999_2.sas7bdat
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

Even though this only converts a single file, the output is partitioned
by the year extracted from the file name as seen below:

    #> output-file-dir
    #> └── bef
    #>     └── year=2020
    #>         └── part-75e043.parquet

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
#> /tmp/RtmpYNMqV6/sas-dir/bef.sas7bdat
#> /tmp/RtmpYNMqV6/sas-dir/bef1999_1.sas7bdat
#> /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat
#> /tmp/RtmpYNMqV6/sas-dir/bef2020.sas7bdat
```

``` r
output_register_dir <- fs::path_temp("output-register-dir")

convert_register(
  path = bef_sas_files,
  output_dir = output_register_dir
)
#> ✔ Converted 'bef.sas7bdat'
#> ✔ Converted 'bef1999_1.sas7bdat'
#> ✔ Converted 'bef1999_2.sas7bdat'
#> ✔ Converted 'bef2020.sas7bdat'
#> ✔ Successfully converted 4 files.
#> • Input: "bef.sas7bdat", "bef1999_1.sas7bdat", "bef1999_2.sas7bdat", and
#>   "bef2020.sas7bdat"
#> • Output: Register files in '/tmp/RtmpYNMqV6/output-register-dir/bef'
```

As with
[`convert_file()`](https://dp-next.github.io/fastreg/reference/convert_file.md),
the output is partitioned by year, extracted from file names.

    #> output-register-dir
    #> └── bef
    #>     ├── year=1999
    #>     │   ├── part-495bdc.parquet
    #>     │   └── part-57e471.parquet
    #>     ├── year=2020
    #>     │   └── part-500b1f.parquet
    #>     └── year=__HIVE_DEFAULT_PARTITION__
    #>         └── part-bb553a.parquet

[`convert_register()`](https://dp-next.github.io/fastreg/reference/convert_register.md)
uses
[`convert_file()`](https://dp-next.github.io/fastreg/reference/convert_file.md)
internally to reads files in chunks (to be able to handle
larger-than-memory data), extracts 4-digit years from filenames for
partitioning, and lowercases column names. See
[`?convert_file`](https://dp-next.github.io/fastreg/reference/convert_file.md)
and
[`?convert_register`](https://dp-next.github.io/fastreg/reference/convert_register.md)
for more details.

There are four different ways that the SAS files can be converted into
Parquet. Using the `bef` register as an example, we have a set of input
SAS files in the `Grunddata/` folder and a set of converted
Hive-partitioned Parquet files in the output folder
`parquet-registers/bef/` that are both listed below:

``` text
# Original SAS files (input)
Grunddata/
├── bef2020.sas7bdat # 1
├── bef2021.sas7bdat # 2
├── December_2023/
│   └── bef2021.sas7bdat # 2
├── bef2022.sas7bdat # 3
└── bef.sas7bdat # 4

# Converted Parquet files (output)
parquet-registers/bef/
├── year=2020/ # 1
│   └── part-c28221.parquet # 1
├── year=2021/ # 2
│   ├── part-bf73dc.parquet # 2
│   └── part-546bed.parquet # 2
├── year=2022/ # 3
│   ├── part-7c041e.parquet # 3
│   └── part-8869b7.parquet # 3
└── year=__HIVE_DEFAULT_PARTITION__/ # 4
    └── part-a8d52c.parquet # 4
```

1.  A single SAS file is converted to a single Parquet file, partitioned
    by year from filename.
2.  Multiple SAS files with the same register and year are converted
    into separate Parquet files in the same partition (shown below).
    Rows between these several SAS files are not deduplicated, so you’ll
    have to check for duplicates after conversion.
3.  A large SAS file is split into multiple Parquet files that are only
    as many rows as is determined by the `chunk_size` option.
4.  A SAS file without a year in file name is placed in the
    `year=__HIVE_DEFAULT_PARTITION__/` folder (the [Apache
    Hive](https://hive.apache.org/docs/latest/user/configuration-properties/)
    default for missing partitions) when it is converted to Parquet.

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
#> ✔ Created '/tmp/RtmpYNMqV6/pipeline-dir/_targets.R'
#> ℹ Edit the `config` section to set your paths.
```

Once the `_targets.R` file is created, open it and edit the `config`
section:

``` r
config <- list(
  input_dir = fs::path_temp("sas-dir"),
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

Below, you can see the output of running the pipeline with the example
data:

    #> parquet-registers
    #> ├── bef
    #> │   ├── year=1999
    #> │   │   ├── part-677898.parquet
    #> │   │   └── part-7fdfcf.parquet
    #> │   ├── year=2020
    #> │   │   └── part-fb4fb1.parquet
    #> │   └── year=__HIVE_DEFAULT_PARTITION__
    #> │       └── part-edb5ed.parquet
    #> └── lmdb
    #>     ├── year=2020
    #>     │   └── part-4cbf7c.parquet
    #>     └── year=2021
    #>         └── part-64edae.parquet

## Reading a Parquet register

The final function reads the converted Parquet register data into R.
This function reads the data into a [DuckDB](https://duckdb.org/) table,
which a powerful way to query and process large data.

``` r
register <- read_register(output_register_dir)
register
#> # Source:   table<arrow_001> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>     koen pnr          foed_dato source_file                                 year
#>    <dbl> <chr>        <chr>     <chr>                                      <int>
#>  1     2 108684730664 19320112  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#>  2     2 982144017357 20070716  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#>  3     2 672580814975 19800805  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#>  4     2 439008110445 20090628  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#>  5     1 489714666740 20170225  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#>  6     2 155331797020 19730330  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#>  7     1 777951655096 19341022  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#>  8     2 167007504860 20010318  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#>  9     1 132473802596 19530901  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#> 10     2 876820784981 19310817  /tmp/RtmpYNMqV6/sas-dir/bef1999_2.sas7bdat  1999
#> # ℹ more rows
```

You can pass a directory to read the full partitioned register or a file
path to read a single `.parquet` file. The data is read lazily, so it
won’t load into memory until collected with
e.g. [`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html).
