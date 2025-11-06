

# registers2parquet: Converting the DST data into Parquet files

<!-- badges: start -->

[![GitHub
License](https://img.shields.io/github/license/dp-next/registers2parquet.svg)](https://github.com/dp-next/registers2parquet/blob/main/LICENSE.md)
[![GitHub
Release](https://img.shields.io/github/v/release/dp-next/registers2parquet.svg)](https://github.com/dp-next/registers2parquet/releases/latest)
[![Build](https://github.com/dp-next/registers2parquet/actions/workflows/build.yml/badge.svg)](https://github.com/dp-next/registers2parquet/actions/workflows/build.yml)
[![pre-commit.ci
status](https://results.pre-commit.ci/badge/github/dp-next/registers2parquet/main.svg)](https://results.pre-commit.ci/latest/github/dp-next/registers2parquet/main)
[![lifecycle](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

The goal of registers2parquet is to take the mess of DST SAS files and
convert them into something more modern, faster, and easier to work
with. And also to prepare the data for our own work.

Want to review the documentation? See the PDF file in the `docs/` folder
by opening the `docs/manual.pdf` file to check out the documentation.
There are sections on “Saving as Parquet” for the code used to save the
data and for reasons on why we’re using this format as well as
“Importing Parquet” for examples on how to work with this format and how
to use a language (DuckDB SQL) to do your work faster.
