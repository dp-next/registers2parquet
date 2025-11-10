# Load a specific register into the R session

**\[deprecated\]**

## Usage

``` r
load_register(name)
```

## Arguments

- name:

  Name of the register to load.

## Value

The register dataset as an Arrow dataset.

## Details

The loaded register will be converted into DuckDB so it can be used via
[`arrow::to_duckdb()`](https://arrow.apache.org/docs/r/reference/to_duckdb.html).
