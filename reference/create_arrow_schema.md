# Create a consistent Arrow schema from a data frame

Maps R types to specific Arrow types to ensure consistent schemas across
chunks and files.

## Usage

``` r
create_arrow_schema(data)
```

## Arguments

- data:

  A data frame to create a schema from.

## Value

An Arrow schema with consistent types.
