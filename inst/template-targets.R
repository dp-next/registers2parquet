# Targets pipeline template for converting SAS registers to Parquet
#
# Setup:
#
# 1. Run `fastreg::use_targets_template()` to copy this template
# 2. Set the `input_dir` and `output_dir` under "Configuration" below
# 3. Run `targets::tar_make()` to convert registers to Parquet
#
# For more information on targets: https://books.ropensci.org/targets/

library(targets)

# Configuration ----------------------------------------------------------------

config <- list(
  # Path to locate SAS files in.
  input_dir = "/path/to/register/sas/files/directory",
  # Path to output Parquet files in. Parquet files will be located in
  # subdirectories of this path.
  output_dir = "/path/to/output/directory"
)

# Validate input path.
if (!dir.exists(config$input_dir)) {
  cli::cli_abort(
    message = "Input directory does not exist: {config$input_dir}"
  )
}

# Target options ---------------------------------------------------------------

tar_option_set(
  packages = c("fs", "fastreg"),
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
    name = sas_paths,
    command = list_sas_files(config$input_dir),
    deployment = "main"
  ),

  tar_target(
    name = register_path_groups,
    command = split_paths_by_register(sas_paths),
    iteration = "list",
    deployment = "main"
  ),

  tar_target(
    name = register_parquets,
    command = convert_to_parquet(
      path = register_path_groups,
      output_dir = config$output_dir
    ),
    pattern = map(register_path_groups)
  )
)
