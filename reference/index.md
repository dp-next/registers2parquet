# Package index

## Convert SAS register files to Parquet

Main functions for converting SAS files containing Danish register data
into Apache Parquet files.

- [`convert_to_parquet()`](https://dp-next.github.io/registers2parquet/reference/convert_to_parquet.md)
  : Convert register SAS file(s) and save to Parquet format

- [`get_database_name()`](https://dp-next.github.io/registers2parquet/reference/get_database_name.md)
  : Get the name of the database from the file name

- [`get_database_year()`](https://dp-next.github.io/registers2parquet/reference/get_database_year.md)
  : Get the year of database from the file name

- [`get_database_year_external()`](https://dp-next.github.io/registers2parquet/reference/get_database_year_external.md)
  : Get the years from the external database's name of the file path.

- [`get_filename_no_ext()`](https://dp-next.github.io/registers2parquet/reference/get_filename_no_ext.md)
  : Get the filename without its file extension

- [`get_parquet_year()`](https://dp-next.github.io/registers2parquet/reference/get_parquet_year.md)
  : Get the year of the parquet file from the file name

- [`get_path_duplicates()`](https://dp-next.github.io/registers2parquet/reference/get_path_duplicates.md)
  : Get paths with duplicate file names

- [`get_path_no_duplicates()`](https://dp-next.github.io/registers2parquet/reference/get_path_no_duplicates.md)
  : Get paths with no duplicate file names

- [`get_path_specific_database()`](https://dp-next.github.io/registers2parquet/reference/get_path_specific_database.md)
  : Get path with specific database file

- [`get_path_with_year()`](https://dp-next.github.io/registers2parquet/reference/get_path_with_year.md)
  : Get path with year in the file name

- [`get_path_without_year()`](https://dp-next.github.io/registers2parquet/reference/get_path_without_year.md)
  : Get path without year in the file name

- [`list_databases()`](https://dp-next.github.io/registers2parquet/reference/list_databases.md)
  :

  Lists all the cleaned Parquet databases in the `cleaned-data` folder

- [`list_dirs()`](https://dp-next.github.io/registers2parquet/reference/list_dirs.md)
  : List directories at given path

- [`list_parquet_files()`](https://dp-next.github.io/registers2parquet/reference/list_parquet_files.md)
  : List Parquet registers in a directory

- [`list_sas_files()`](https://dp-next.github.io/registers2parquet/reference/list_sas_files.md)
  : List SAS registers in a directory

- [`path_alter_filename_as_dir()`](https://dp-next.github.io/registers2parquet/reference/path_alter_filename_as_dir.md)
  :

  Convert path to end with `filename/`

- [`path_alter_filename_year_as_dir()`](https://dp-next.github.io/registers2parquet/reference/path_alter_filename_year_as_dir.md)
  :

  Convert file name of a path to end in `/year=YYYY`

- [`path_alter_to_cleaned_dir()`](https://dp-next.github.io/registers2parquet/reference/path_alter_to_cleaned_dir.md)
  : Convert path to cleaned directory.

- [`path_alter_to_output_parquet_partition()`](https://dp-next.github.io/registers2parquet/reference/path_alter_to_output_parquet_partition.md)
  : Convert the path to represent a Parquet Partition in another
  directory

- [`path_as_df()`](https://dp-next.github.io/registers2parquet/reference/path_as_df.md)
  : Create dataframe with path and file name

- [`path_duplicates_as_list()`](https://dp-next.github.io/registers2parquet/reference/path_duplicates_as_list.md)
  : Get duplicate paths as a list

- [`path_eksterne_dir()`](https://dp-next.github.io/registers2parquet/reference/path_eksterne_dir.md)
  : Path to external directory

- [`path_ext_set_parquet_partition()`](https://dp-next.github.io/registers2parquet/reference/path_ext_set_parquet_partition.md)
  : Convert file path to Parquet Partition

- [`path_grunddata_dir()`](https://dp-next.github.io/registers2parquet/reference/path_grunddata_dir.md)
  : Path to "grunddata" directory

- [`path_parquet_dirs()`](https://dp-next.github.io/registers2parquet/reference/path_parquet_dirs.md)
  : Path to Parquet directory

- [`path_parquet_external()`](https://dp-next.github.io/registers2parquet/reference/path_parquet_external.md)
  : Path to external Parquet files

- [`path_parquet_registers()`](https://dp-next.github.io/registers2parquet/reference/path_parquet_registers.md)
  : Path to Parquet registers

- [`path_population_file()`](https://dp-next.github.io/registers2parquet/reference/path_population_file.md)
  : Path to population file

- [`path_rawdata()`](https://dp-next.github.io/registers2parquet/reference/path_rawdata.md)
  : Path to rawdata directory

- [`path_sas_formats()`](https://dp-next.github.io/registers2parquet/reference/path_sas_formats.md)
  : Path to SAS formats

- [`path_set_dir()`](https://dp-next.github.io/registers2parquet/reference/path_set_dir.md)
  : Alter the path of a file to a Parquet partition in another directory

- [`path_subdir()`](https://dp-next.github.io/registers2parquet/reference/path_subdir.md)
  : Path to subdirectory

- [`path_workdata()`](https://dp-next.github.io/registers2parquet/reference/path_workdata.md)
  : Path to workdata directory

- [`read_register()`](https://dp-next.github.io/registers2parquet/reference/read_register.md)
  : Read a Parquet register
