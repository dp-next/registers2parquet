# Package index

## Main functions

- [`convert_to_parquet()`](https://dp-next.github.io/fastreg/reference/convert_to_parquet.md)
  : Convert register SAS file(s) and save to Parquet format
- [`read_register()`](https://dp-next.github.io/fastreg/reference/read_register.md)
  : Read a Parquet register

## Helper functions

- [`list_parquet_files()`](https://dp-next.github.io/fastreg/reference/list_parquet_files.md)
  : List Parquet files in a directory
- [`list_sas_files()`](https://dp-next.github.io/fastreg/reference/list_sas_files.md)
  : List SAS files in a directory
- [`use_targets_pipeline()`](https://dp-next.github.io/fastreg/reference/use_targets_pipeline.md)
  : Set up a targets pipeline for converting SAS registers to Parquet

## Functions used within the targets pipeline

These functions are not expected to be used outside the targets pipeline
created with the template.

- [`get_register_name()`](https://dp-next.github.io/fastreg/reference/get_register_name.md)
  : Get register name from a group of file paths
- [`split_paths_by_register()`](https://dp-next.github.io/fastreg/reference/split_paths_by_register.md)
  : Group file paths by register name
