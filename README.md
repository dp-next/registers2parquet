

# fastreg <a href="https://dp-next.github.io/fastreg/"><img src="man/figures/logo.svg" align="right" height="139" alt="fastreg website" /></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/fastreg)](https://CRAN.R-project.org/package=fastreg)
[![GitHub
Release](https://img.shields.io/github/v/release/dp-next/fastreg.svg)](https://github.com/dp-next/fastreg/releases/latest)
[![Build](https://github.com/dp-next/fastreg/actions/workflows/build.yml/badge.svg)](https://github.com/dp-next/fastreg/actions/workflows/build.yml)
[![pre-commit.ci
status](https://results.pre-commit.ci/badge/github/dp-next/fastreg/main.svg)](https://results.pre-commit.ci/latest/github/dp-next/fastreg/main)
[![lifecycle](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

<!-- badges: end -->

## Overview

fastreg converts large SAS register files (`.sas7bdat`) into [Apache
Parquet](https://parquet.apache.org/) format. This is particularly
useful for researchers working with Danish registers at Statistics
Denmark, where large SAS files are common. Parquet files are smaller on
disk, faster to read, and work well with modern tools like
[DuckDB](https://r.duckdb.org/) and
[Arrow](https://arrow.apache.org/docs/r/).

A *register* in this context refers to a collection of related data
files, typically with yearly snapshots like `bef2020.sas7bdat`,
`bef2021.sas7bdat` (from the
[BEF](https://dst.dk/extranet/ForskningVariabellister/BEF%20-%20Befolkningen.html)
register).

fastreg provides functions to:

- Convert SAS files to Parquet.
- Read Parquet registers.
- Create a [targets](https://docs.ropensci.org/targets/) pipeline from a
  template for parallel conversion.
- List SAS and Parquet files in directories.

## Purpose

The primary purpose of the fastreg package is to simplify the process of
converting the large Danish registers into the more modern Parquet
storage format as well as to simplify reading these Parquet files. By
converting data from SAS to the more modern and efficient Parquet
format, the package reduces storage costs and aims to improve
performance in data analysis workflows.

## Installation

Install from CRAN:

``` r
install.packages("fastreg")
```

Install the latest development version from GitHub:

``` r
pak::pak("dp-next/fastreg")
```

## Usage

Use `convert()` to convert a single SAS file to Parquet in Hive
partition format:

``` r
fastreg::convert(
  path = "path/to/file.sas7bdat",
  output_dir = "path/to/output_dir/"
)
```

Use `use_template()` to copy a
[targets](https://books.ropensci.org/targets/) template that converts
multiple registers in parallel into your project:

``` r
fastreg::use_template()
```

Use `read_register()` to quickly read a specific register (e.g. the BEF
register) as a DuckDB table:

``` r
fastreg::read_register("bef")
```

See `vignette("fastreg")` for a complete guide.

## Getting help

If you find a bug or have any questions, please add an
[Issue](https://github.com/dp-next/fastreg/issues) on GitHub. Please
include a minimal reproducible example.

## Code of conduct

Please note that the fastreg project is released with a [Contributor
Code of
Conduct](https://dp-next.github.io/fastreg/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
