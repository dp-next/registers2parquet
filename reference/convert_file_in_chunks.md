# Convert a single register SAS file to Parquet in chunks

Convert a single register SAS file to Parquet in chunks

## Usage

``` r
convert_file_in_chunks(file_path, output_dir, chunk_size = 10000000L)
```

## Arguments

- file_path:

  A character scalar with the absolute path to a single SAS file.

- output_dir:

  A character scalar with the path to the directory to save the output
  Parquet file to. Should include the register name as the last part of
  the path. E.g., `path/to/register_name/`.

- chunk_size:

  An integer scalar indicating the number of rows to read at a time from
  the SAS files. Defaults to 10,000,000.

## Value

file_path invisibly.
