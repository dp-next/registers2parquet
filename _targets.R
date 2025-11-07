# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Packages and settings ---------------------------------------------------

# Load packages required to define the pipeline:
options(tidyverse.quiet = TRUE)
library(tidyverse)
library(targets)
library(future)
library(future.callr)
library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = desc::desc_get_deps()$package,
  format = "qs", # Optionally set the default storage format. qs is fast.
  # For distributed computing in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs.
  controller = crew::crew_controller_local(
    # Don't use too many, some datasets get big and use up all the memory
    workers = 12
  ),
  # Sometimes saving to drive is slow to respond, increase time-out
  resources = tar_resources(
    network = tar_resources_network(seconds_timeout = 180)
  ),
  # To keep running the pipeline even with errors
  error = "null",
  memory = "transient",
  garbage_collection = TRUE
)

# Pre-target setup --------------------------------------------------------

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Targets in pipeline -----------------------------------------------------

# In general, the targets follow the pattern "input path -> output path",
# so all functions also follow that pattern as well.

list(
  # Convert population file -------------------------------------------------
  tar_target(
    name = population_path,
    command = path_population_file("708421")
  ),
  tar_target(
    name = population_parquet_database,
    command = sas_to_parquet(
      input_path = population_path,
      output_path = population_path |>
        path_alter_to_cleaned_dir("parquet-external")
    ),
    format = "file"
  ),

  # Convert external data files -------------------------------------------
  # TODO: Will have to check this is true with later data additions.
  tar_target(
    name = sas_database_paths_external,
    command = path_eksterne_dir("708421") |>
      list_sas_files() |>
      path_as_df() |>
      # These are huge, need to do them outside of targets (see end of this script)
      dplyr::filter(
        !get_database_name(file) %in% c("lab_forsker", "lab_dm_forsker")
      ) |>
      dplyr::pull(path) |>
      path_duplicates_as_list()
  ),
  tar_target(
    name = external_parquet_database,
    command = sas_to_parquet(
      input_path = sas_database_paths_external,
      output_path = sas_database_paths_external |>
        purrr::map_chr(
          ~ {
            .x |>
              path_alter_to_cleaned_dir("parquet-external") |>
              unique()
          }
        )
    ),
    format = "file",
    pattern = map(sas_database_paths_external),
    iteration = "list"
  ),

  # Convert register data files ---------------------------------------------
  tar_target(
    name = sas_database_paths_grunddata,
    command = path_grunddata_dir("708421") |>
      list_sas_files() |>
      path_duplicates_as_list()
  ),
  tar_target(
    name = grunddata_parquet_database,
    command = sas_to_parquet(
      input_path = sas_database_paths_grunddata,
      output_path = sas_database_paths_grunddata |>
        purrr::map_chr(
          ~ {
            .x |>
              path_alter_to_cleaned_dir("parquet-registers") |>
              unique()
          }
        )
    ),
    format = "file",
    pattern = map(sas_database_paths_grunddata),
    iteration = "list"
  ),

  # Build PDF manual --------------------------------------------------------
  # Can also rebuild with `build_docs()`.
  tar_quarto(
    name = build_pdf_manual,
    path = "vignettes"
  )
)

# Build lab forsker database ----------------------------------------------
# lab_forsker_path <- list_massive_files()

# vroom::vroom(lab_forsker_path[1],
#              n_max = 10)

# vroom::vroom(lab_forsker_path[2]) |>
#   arrow::write_parquet(
#     lab_forsker_path[2] |>
#       path_alter_to_cleaned_dir("parquet-external")
#   )

# TODO: these large datasets have some issues, need to look into them more.
# This at least connects.
# arrow::open_csv_dataset(lab_forsker_path[1])
