# Targets pipeline template for converting SAS registers to Parquet
#
# SETUP:
# 1. Run `registers2parquet::use_targets_pipeline()` to copy this template
# 2. Set the `input_path` and `output_path` under "Configuration" below
# 3. Run `targets::tar_make()` to convert registers to Parquet
#
# For more information on targets: https://books.ropensci.org/targets/

library(targets)

# Configuration ----------------------------------------------------------------

config <- list(
  # Path to locate SAS files in.
  input_path = "/path/to/register/sas/files/directory",
  # Path to output Parquet files in. Parquet files will be located in
  # subdirectories of this path.
  output_path = "/path/to/output/directory"
)

# Validate input path.
if (!dir.exists(config$input_path)) {
  stop("Input directory does not exist: ", config$input_path, call. = FALSE)
}

# Target options ---------------------------------------------------------------

tar_option_set(
  packages = c("fs", "registers2parquet"),
  format = "qs",
  # Set controller with max 10 workers run as local R processes, launching
  # when there's work to do and exiting after 60 seconds if there's no task to
  # run.
  # NOTE: 10 workers might be too many for some systems.
  controller = crew::crew_controller_local(
    workers = 10,
    seconds_idle = 60
  ),
  # Delegate data management to the parallel crew workers.
  storage = "worker",
  retrieval = "worker",

  # Remove data from the R environment as soon as it's no longer needed. But
  # computer memory is not freed until garbage collection is run.
  memory = "transient",
  # Run gc() every 10th active target, both locally and on each parallel worker.
  garbage_collection = 10
)

# Pipeline ---------------------------------------------------------------------

list(
  tar_target(
    name = all_sas_paths,
    command = registers2parquet::list_sas_files(config$input_path),
    deployment = "main"
  ),

  tar_target(
    name = register_path_groups,
    command = registers2parquet::get_register_path_groups(all_sas_paths),
    iteration = "list",
    deployment = "main"
  ),

  tar_target(
    name = register_parquets,
    command = registers2parquet::convert_to_parquet(
      paths = register_path_groups,
      output_path = fs::path(
        config$output_path,
        registers2parquet::get_first_register_name(register_path_groups)
      )
    ),
    pattern = map(register_path_groups),
    format = "file"
  )
)
