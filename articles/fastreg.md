# Getting started

One of the main purposes of fastreg is to ease the conversion of SAS
register files (`.sas7bdat`) into
[Parquet](https://parquet.apache.org/). A *register* in this context
refers to a collection of related data files that belong to the same
dataset, typically with yearly snapshots (e.g.,
`kontakter2020.sas7bdat`, `kontakter2021.sas7bdat`).

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
registers, `kontakter` and `diagnoser`:

Show setup code

``` r
library(fastreg)

sas_dir <- fs::path_temp("sas-dir")
fs::dir_create(sas_dir)

kontakter_list <- simulate_register(
  "kontakter",
  c("", "1999_1", "1999_2", "2020"),
  n = 1000
)

diagnoser_list <- simulate_register(
  "diagnoser",
  c("2020", "2021"),
  n = 1000
)

save_as_sas(
  c(kontakter_list, diagnoser_list),
  sas_dir
)
```

    #> sas-dir
    #> ├── diagnoser2020.sas7bdat
    #> ├── diagnoser2021.sas7bdat
    #> ├── kontakter.sas7bdat
    #> ├── kontakter1999_1.sas7bdat
    #> ├── kontakter1999_2.sas7bdat
    #> └── kontakter2020.sas7bdat

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
sas_file <- fs::path(sas_dir, "kontakter2020.sas7bdat")
output_file_dir <- fs::path_temp("output-file-dir")

convert_file(
  path = sas_file,
  output_dir = output_file_dir
)
#> ✔ Converted 'kontakter2020.sas7bdat'
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
    #> └── kontakter
    #>     └── year=2020
    #>         └── part-49fb31.parquet

## Converting a register

Use
[`list_sas_files()`](https://dp-next.github.io/fastreg/reference/list_sas_files.md)
to find SAS files in a directory (and any subdirectories), then use
[`convert_register()`](https://dp-next.github.io/fastreg/reference/convert_register.md)
to convert them.
[`convert_register()`](https://dp-next.github.io/fastreg/reference/convert_register.md)
expects files to be from the **same register** based on file names.

``` r
kontakter_sas_files <- list_sas_files(sas_dir) |>
  stringr::str_subset("kontakter")
kontakter_sas_files
#> /tmp/RtmpuQgOBq/sas-dir/kontakter.sas7bdat
#> /tmp/RtmpuQgOBq/sas-dir/kontakter1999_1.sas7bdat
#> /tmp/RtmpuQgOBq/sas-dir/kontakter1999_2.sas7bdat
#> /tmp/RtmpuQgOBq/sas-dir/kontakter2020.sas7bdat
```

``` r
output_register_dir <- fs::path_temp("output-register-dir")

convert_register(
  path = kontakter_sas_files,
  output_dir = output_register_dir
)
#> ✔ Converted 'kontakter.sas7bdat'
#> ✔ Converted 'kontakter1999_1.sas7bdat'
#> ✔ Converted 'kontakter1999_2.sas7bdat'
#> ✔ Converted 'kontakter2020.sas7bdat'
#> ✔ Successfully converted 4 files.
#> • Input: "kontakter.sas7bdat", "kontakter1999_1.sas7bdat",
#>   "kontakter1999_2.sas7bdat", and "kontakter2020.sas7bdat"
#> • Output: Register files in '/tmp/RtmpuQgOBq/output-register-dir/kontakter'
```

As with
[`convert_file()`](https://dp-next.github.io/fastreg/reference/convert_file.md),
the output is partitioned by year, extracted from file names.

    #> output-register-dir
    #> └── kontakter
    #>     ├── year=1999
    #>     │   ├── part-8cb892.parquet
    #>     │   └── part-ef768d.parquet
    #>     ├── year=2020
    #>     │   └── part-54ddc2.parquet
    #>     └── year=__HIVE_DEFAULT_PARTITION__
    #>         └── part-82587d.parquet

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
#> ✔ Created '/tmp/RtmpuQgOBq/pipeline-dir/_targets.R'
#> ℹ Edit the `config` section to set your paths.
```

Once the `_targets.R` file is created, open it and edit the `config`
section:

``` r
config <- list(
  input_dir = fs::path_temp("sas-dir"),
  output_dir = fs::path_temp("parquet-registers")
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
    #> ├── diagnoser
    #> │   ├── year=2020
    #> │   │   └── part-104af6.parquet
    #> │   └── year=2021
    #> │       └── part-c42bfd.parquet
    #> └── kontakter
    #>     ├── year=1999
    #>     │   ├── part-d54bef.parquet
    #>     │   └── part-f4101e.parquet
    #>     ├── year=2020
    #>     │   └── part-93b8da.parquet
    #>     └── year=__HIVE_DEFAULT_PARTITION__
    #>         └── part-84288d.parquet

## Reading a Parquet register

The final function reads the converted Parquet register data into R.
This function reads the data into a [DuckDB](https://duckdb.org/) table,
which a powerful way to query and process large data.

``` r
register <- read_register(output_register_dir)
register
#> # Source:   table<arrow_001> [?? x 6]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cpr          dw_ek_kontakt     dato_start hovedspeciale_ans source_file  year
#>    <chr>        <chr>             <chr>      <chr>             <chr>       <int>
#>  1 108684730664 9201662543457744… 20170316   Fysio- og ergote… /tmp/Rtmpu…  1999
#>  2 982144017357 0759727820625697… 20081030   Thoraxkirurgi     /tmp/Rtmpu…  1999
#>  3 672580814975 1765362830036030… 19781226   Klinisk immunolo… /tmp/Rtmpu…  1999
#>  4 439008110445 5816242949650462… 20040706   Akut medicin      /tmp/Rtmpu…  1999
#>  5 489714666740 8142102823445808… 20160613   Karkirurgi        /tmp/Rtmpu…  1999
#>  6 155331797020 3938857359733134… 20001231   Nefrologi         /tmp/Rtmpu…  1999
#>  7 777951655096 8361795065466867… 20250325   Diagnostisk radi… /tmp/Rtmpu…  1999
#>  8 167007504860 8141754368465387… 19961124   Pædiatri          /tmp/Rtmpu…  1999
#>  9 132473802596 5081335938814873… 19970403   Klinisk immunolo… /tmp/Rtmpu…  1999
#> 10 876820784981 3250770638911327… 19990709   Geriatri          /tmp/Rtmpu…  1999
#> # ℹ more rows
```

You can pass a directory to read the full partitioned register or a file
path to read a single `.parquet` file. The data is read lazily, so it
won’t load into memory until collected with
e.g. [`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html).
