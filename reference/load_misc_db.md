# Load a specific misc database into the R session

**\[deprecated\]**

## Usage

``` r
load_misc_db(name)
```

## Arguments

- name:

  Name of the register to load.

## Value

The register dataset as an Arrow dataset.

## Details

The loaded database will be converted into DuckDB so it can be used via
[`arrow::to_duckdb()`](https://arrow.apache.org/docs/r/reference/to_duckdb.html).
