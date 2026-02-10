# Getting started

fastreg eases the conversion of SAS register files (`.sas7bdat`) into
[Parquet](https://parquet.apache.org/). In this context, a *register*
refers to a collection of related data files that belong to the same
dataset, typically with yearly snapshots (e.g.,
`kontakter_2020.sas7bdat`, `kontakter_2021.sas7bdat`).

## Why Parquet?

[Parquet](https://parquet.apache.org/) is a columnar storage file format
optimised for analytical workloads. Compared to
[SAS](https://fileinfo.com/extension/sas7bdat) files (and row-based
formats like CSV), Parquet offers:

- **Reduced storage**: Efficient compression significantly reduces disk
  space, especially for large datasets.
- **Faster queries**: The columnar layout speeds up analytical queries
  that only need a subset of columns.
- **Wide tool support**: Parquet is supported across data processing
  frameworks in [R](https://www.r-project.org/),
  [Python](https://www.python.org/), and beyond, making it easy to
  integrate into modern workflows.

## Setup

For the examples below, we simulate SAS register data for two registers,
`kontakter` and `diagnoser`:

Show setup code

``` r
library(fastreg)

sas_dir <- fs::path_temp("sas-dir")
kontakter_dir <- fs::path(sas_dir, "kontakter")
diagnoser_dir <- fs::path(sas_dir, "diagnoser")
fs::dir_create(kontakter_dir)
fs::dir_create(diagnoser_dir)

kontakter_list <- simulate_register(
  "kontakter",
  c("", "1999_1", "1999_2", "2020"),
  n = 1000
)
save_as_sas(kontakter_list, kontakter_dir)

diagnoser_list <- simulate_register(
  "diagnoser",
  c("2020", "2021"),
  n = 1000
)
save_as_sas(diagnoser_list, diagnoser_dir)
```

    #> sas-dir
    #> ├── diagnoser
    #> │   ├── diagnoser_2020.sas7bdat
    #> │   └── diagnoser_2021.sas7bdat
    #> └── kontakter
    #>     ├── kontakter.sas7bdat
    #>     ├── kontakter_1999_1.sas7bdat
    #>     ├── kontakter_1999_2.sas7bdat
    #>     └── kontakter_2020.sas7bdat

## Converting a single register

Use
[`list_sas_files()`](https://dp-next.github.io/fastreg/reference/list_sas_files.md)
to find SAS files in a directory (and any subdirectories), then use
[`convert_to_parquet()`](https://dp-next.github.io/fastreg/reference/convert_to_parquet.md)
to convert them.
[`convert_to_parquet()`](https://dp-next.github.io/fastreg/reference/convert_to_parquet.md)
expects files to be from the **same register** based on file names.

``` r
kontakter_sas_files <- list_sas_files(kontakter_dir)
kontakter_sas_files
#> /tmp/RtmpOfCB7t/sas-dir/kontakter/kontakter_1999_1.sas7bdat
#> /tmp/RtmpOfCB7t/sas-dir/kontakter/kontakter_1999_2.sas7bdat
#> /tmp/RtmpOfCB7t/sas-dir/kontakter/kontakter_2020.sas7bdat
#> /tmp/RtmpOfCB7t/sas-dir/kontakter/kontakter.sas7bdat
```

``` r
output_dir <- fs::path_temp("output-dir")

convert_to_parquet(
  path = kontakter_sas_files,
  output_dir = output_dir
)
#> ✔ Successfully converted "kontakter_1999_1.sas7bdat", "kontakter_1999_2.sas7bdat", "kontakter_2020.sas7bdat", and "kontakter.sas7bdat" and saved it in '/tmp/RtmpOfCB7t/output-dir'.
```

The output is partitioned by year, extracted from filenames:

    #> output-dir
    #> ├── year=1999
    #> │   ├── part-9b0cce.parquet
    #> │   └── part-d9fa35.parquet
    #> ├── year=2020
    #> │   └── part-65c619.parquet
    #> └── year=__HIVE_DEFAULT_PARTITION__
    #>     └── part-4ca66e.parquet

[`convert_to_parquet()`](https://dp-next.github.io/fastreg/reference/convert_to_parquet.md)
reads files in chunks (to be able to handle larger-than-memory data),
extracts 4-digit years from filenames for partitioning, and lowercases
column names. See
[`?convert_to_parquet`](https://dp-next.github.io/fastreg/reference/convert_to_parquet.md)
for more details.

> **Conversion scenarios example**
>
> The diagram below shows four scenarios when converting a SAS register
> files for a register called `bef`:
>
> #### Input: SAS files
>
>     sas_dir/
>     ├── A) bef2020.sas7bdat
>     ├── B) bef2021.sas7bdat
>     ├── December_2023/
>     │   └── B) bef2021.sas7bdat
>     ├── C) bef2022.sas7bdat
>     └── D) bef.sas7bdat
>
> #### Output: Parquet files
>
>     bef/
>     ├── year=2020/
>     │   └── part-c28221.parquet
>     ├── year=2021/
>     │   ├── part-bf73dc.parquet
>     │   └── part-546bed.parquet
>     ├── year=2022/
>     │   ├── part-7c041e.parquet
>     │   └── part-8869b7.parquet
>     └── year=__HIVE_DEFAULT_PARTITION__/
>         └── part-a8d52c.parquet
>
> 1.  Single file → single Parquet file, partitioned by year from
>     filename.
> 2.  Multiple files with the same year → separate Parquet files in the
>     same partition. Identical rows are not deduplicated.
> 3.  Large file → split into multiple Parquet files due to more rows in
>     than `chunk_size`.
> 4.  File without year in name → placed in
>     `year=__HIVE_DEFAULT_PARTITION__` (the [Apache
>     Hive](https://hive.apache.org/docs/latest/user/configuration-properties/)
>     default for missing partitions).

## Converting multiple registers in parallel

For many or large files, fastreg provides a
[targets](https://docs.ropensci.org/targets/) pipeline template that
parallelises conversion across CPU cores. By default it uses 10 workers,
but that can be adjusted in the pipeline to fit the available resources.

### Create the pipeline file

``` r
# Create temp directory for example.
pipeline_dir <- fs::path_temp("pipeline-dir")
fs::dir_create(pipeline_dir)

use_targets_template(path = fs::path(pipeline_dir, "_targets.R"))
#> ✔ Created '/tmp/RtmpOfCB7t/pipeline-dir/_targets.R'
#> ℹ Edit the `config` section to set your paths.
```

### Set input and output paths

Open `_targets.R` and edit the `config` section:

``` r
config <- list(
  input_path = fs::path_temp("sas-dir"),
  output_path = fs::path_temp("parquet-registers")
)
```

- **`input_path`**: directory containing SAS files (searched
  recursively).
- **`output_path`**: directory where Parquet files will be written.

### Run the pipeline

``` r
targets::tar_make()
```

The pipeline finds all SAS files, groups them by register name, and
converts each in parallel. Re-running `tar_make()` only re-converts
registers whose source files have changed.

    #> parquet-registers
    #> ├── diagnoser
    #> │   ├── year=2020
    #> │   │   └── part-f6a492.parquet
    #> │   └── year=2021
    #> │       └── part-90edc3.parquet
    #> └── kontakter
    #>     ├── year=1999
    #>     │   ├── part-af69b2.parquet
    #>     │   └── part-f71c49.parquet
    #>     ├── year=2020
    #>     │   └── part-474459.parquet
    #>     └── year=__HIVE_DEFAULT_PARTITION__
    #>         └── part-d98b47.parquet

## Reading a Parquet register

Use
[`read_register()`](https://dp-next.github.io/fastreg/reference/read_register.md)
to read converted data as a DuckDB table:

``` r
register <- read_register(output_dir)
register
#> # Source:   table<arrow_001> [?? x 6]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cpr          dw_ek_kontakt     dato_start hovedspeciale_ans source_file  year
#>    <chr>        <chr>             <chr>      <chr>             <chr>       <int>
#>  1 108684730664 9201662543457744… 20170316   Fysio- og ergote… /tmp/RtmpO…  1999
#>  2 982144017357 0759727820625697… 20081030   Thoraxkirurgi     /tmp/RtmpO…  1999
#>  3 672580814975 1765362830036030… 19781226   Klinisk immunolo… /tmp/RtmpO…  1999
#>  4 439008110445 5816242949650462… 20040706   Akut medicin      /tmp/RtmpO…  1999
#>  5 489714666740 8142102823445808… 20160613   Karkirurgi        /tmp/RtmpO…  1999
#>  6 155331797020 3938857359733134… 20001231   Nefrologi         /tmp/RtmpO…  1999
#>  7 777951655096 8361795065466867… 20250325   Diagnostisk radi… /tmp/RtmpO…  1999
#>  8 167007504860 8141754368465387… 19961124   Pædiatri          /tmp/RtmpO…  1999
#>  9 132473802596 5081335938814873… 19970403   Klinisk immunolo… /tmp/RtmpO…  1999
#> 10 876820784981 3250770638911327… 19990709   Geriatri          /tmp/RtmpO…  1999
#> # ℹ more rows
```

You can pass a directory to read the full partitioned register or a file
path to read a single `.parquet` file. The data is read lazily, so it
won’t load into memory until collected with
e.g. [`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html).
