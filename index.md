# fastreg

## Overview

fastreg converts large SAS register files (`.sas7bdat`) into [Apache
Parquet](https://parquet.apache.org/) format. This is particularly
useful for researchers working with Danish registers at Statistics
Denmark, where large SAS files are common. Parquet files are smaller on
disk, faster to read, and work well with modern tools like
[DuckDB](https://r.duckdb.org/) and
[Arrow](https://arrow.apache.org/docs/r/).

A *register* in this context refers to a collection of related data
files, typically with yearly snapshots like `kontakter_2020.sas7bdat`,
`kontakter_2021.sas7bdat` (from Landspatientregisteret, LPR3).

fastreg provides functions to:

- Convert SAS files to Parquet.
- Read Parquet registers.
- Create a [targets](https://docs.ropensci.org/targets/) pipeline from a
  template for parallel batch conversion.
- List SAS and Parquet files in directories.

## Purpose

The primary purpose of the fastreg package is to simplify the process of
converting the large Danish registers into the more modern Parquet
storage format as well as to simplify reading these Parquet files. By
converting data from SAS to the more modern and efficient Parquet
format, the package reduces storage costs and aims to improve
performance in data analysis workflows.

## Installation

``` r
# install.packages("fastreg")

# Development version on GitHub
pak::pak("dp-next/fastreg")
```

## Usage

``` r
library(fastreg)

# Convert SAS files to Parquet
convert_to_parquet(
  path = list_sas_files("path/to/sas_register/"),
  output_dir = "path/to/parquet_register/"
)

# Read Parquet register (as DuckDB table)
read_register("path/to/parquet_register/")

# Use targets template
use_targets_template()

# List files
list_sas_files("path/to/directory/with/sas_files")
list_parquet_files("path/to/directory/with/parquet_files")
```

See
[`vignette("fastreg")`](https://dp-next.github.io/fastreg/articles/fastreg.md)
for a complete guide.

## Getting help

If you find a bug or have any questions, please add an
[Issue](https://github.com/dp-next/fastreg/issues) on GitHub. Please
include a minimal reproducible example.

## Code of conduct

This project is released with a [Code of
conduct](https://dp-next.github.io/fastreg/CODE_OF_CONDUCT.md). By
contributing to this project you agree to follow its terms.
