

# fastreg

<!-- badges: start -->

[![GitHub
Release](https://img.shields.io/github/v/release/%7B%7B%3C%20meta%20gh.org%20%3E%7D%7D/%7B%7B%3C%20meta%20gh.repo%20%3E%7D%7D.svg)](https://github.com/dp-next/fastreg/releases/latest)
[![Build](https://github.com/%7B%7B%3C%20meta%20gh.org%20%3E%7D%7D/%7B%7B%3C%20meta%20gh.repo%20%3E%7D%7D/actions/workflows/build.yml/badge.svg)](https://github.com/dp-next/fastreg/actions/workflows/build.yml)
[![pre-commit.ci
status](https://results.pre-commit.ci/badge/github/%7B%7B%3C%20meta%20gh.org%20%3E%7D%7D/%7B%7B%3C%20meta%20gh.repo%20%3E%7D%7D/main.svg)](https://results.pre-commit.ci/latest/github/dp-next/fastreg/main)
[![lifecycle](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

<!-- badges: end -->

## Overview

fastreg simplifies converting large SAS register files (`.sas7bdat`)
into [Apache Parquet](https://parquet.apache.org/) format. This is
particularly useful for researchers working with Danish registers at
Statistics Denmark, where large SAS files are common. Parquet files are
smaller on disk, faster to read, and work well with modern tools like
[DuckDB](https://r.duckdb.org/) and
[Arrow](https://arrow.apache.org/docs/r/).

A *register* in this context refers to a collection of related data
files, typically with yearly snapshots like `kontakter_2020.sas7bdat`,
`kontakter_2021.sas7bdat` (from Landspatientregisteret, LPR3).

fastreg provides functions to:

- Convert SAS files to Parquet
- Read Parquet registers
- Copy a [targets](https://docs.ropensci.org/targets/) pipeline template
  for parallel batch conversion
- List SAS and Parquet files in directories

## Installation

<!-- TODO: Uncomment when released to CRAN -->

``` r
#install.packages("fastreg")

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

See `vignette("fastreg")` for a complete guide.

## Getting help

If you find a bug or have any questions, please add an
[Issue](https://github.com/dp-next/fastreg/issues) on GitHub. Please
include a minimal reproducible example.

## Code of conduct

This project is released with a [Code of conduct](CODE_OF_CONDUCT.md).
By contributing to this project you agree to follow its terms.
