# Create UUID for partition part

We're using shortened UUIDs instead of integers to avoid collisions when
converting registers in parallel.

## Usage

``` r
create_part_uuid()
```

## Value

A character scalar with a UUID with a length of 4.
