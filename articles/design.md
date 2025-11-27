# Design

## Core functionality

This is the list of the core functionality in the `registers2parquet`
package:

1.  Converts Danish register data from SAS files to the modern and
    efficient Parquet format.
2.  Read register Parquet files into R as a DuckDB table.
3.  Provides functions to list available SAS or Parquet register files
    directly from R.

## Parallel processing

Each register-year pairing (including duplicate years) are sent to a
separate process. That way, rather than converting 1000+ registers one
after the other, it can be split into chunks based on the number of
available CPU cores. For instance, if you set the number of “workers”
(cores) to 4, than the 1000+ registers will be split into 4 groups and
each group will be processed simultaneously on its own core.

There are some overheads to parallel processing, so it works best with a
large number of files and when the files are also relatively large, or
if the processing time per file is substantial.

## Visual representation of data flow

``` mermaid
flowchart LR
    subgraph SAS [SAS Files]
        direction TB
        A1[bef2018.sas7bdat]
        A2[bef2019.sas7bdat]
        A3[bef2020.sas7bdat]
        A4[bef2021.sas7bdat]
        A5[bef2022.sas7bdat]
        A6[December_2023/bef2022.sas7bdat]
        A7[December_2023/bef2023.sas7bdat]
    end

    subgraph Parquet [Parquet Files]
        direction TB
        B1[bef/year=2018/part-0.parquet]
        B2[bef/year=2019/part-0.parquet]
        B3[bef/year=2020/part-0.parquet]
        B4[bef/year=2021/part-0.parquet]
        B5[bef/year=2022/part-0.parquet]
        B6[bef/year=2023/part-0.parquet]
    end

    F1[Data]
    F2[Data]
    F3[Data]
    F4[Data]
    F5[Data]
    F6[Data]

    A1 -->|import| F1 -->|export| B1
    A2 -->|import| F2 -->|export| B2
    A3 -->|import| F3 -->|export| B3
    A4 -->|import| F4 -->|export| B4
    A5 -->|import &<br>join| F5
    A6 -->|import &<br>join| F5
    F5 -->|export| B5
    A7 -->|import| F6 -->|export| B6

    %% Styling
    style SAS fill:#FFFFFF, color:#000000
    style Parquet fill:#FFFFFF, color:#000000
```

## Naming conventions

In the sections below, we outline the naming conventions of actions and
objects in the package. **Actions** are verbs that describe what a
function does, while **objects** are nouns that represent the parameters
that the functions operate on.

### Actions

| Action  | Description                                                                                                |
|---------|------------------------------------------------------------------------------------------------------------|
| convert | Convert a register SAS file (or multiple) to Parquet.                                                      |
| get     | Used for internal helper functions to e.g., get or extract the year from a file name.                      |
| list    | List or retrieve an object or multiple objects. E.g., a path, a register name, or a year from a file name. |
| read    | Read a Parquet register into R as a DuckDB table.                                                          |

Actions used in `registers2parquet`.

### Objects

| Object          | Description                                                                                                                                                                                                |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `output_path`   | A character scalar with the absolute path to the directory where the Parquet file should be created in.                                                                                                    |
| `path`          | A character vector with the absolute path to a file or directory. It can be a single path or multiple paths as a character vector. Is used in functions to list available files or to specify input files. |
| `project_id`    | A character scalar with the DST project number to the folder containing the raw or work data.                                                                                                              |
| `register_name` | A character scalar with the name of a register used in the file name (without a path), e.g., “bef”. It’s used in `list` functions to retrieve the paths of objects including that name.                    |

Objects used in `registers2parquet`.

## Interface

`registers2parquet` includes two main functions and multiple helper
functions. Each function is listed below with a short description.

> **Tip**
>
> See the [Reference
> documentation](https://dp-next.github.io/registers2parquet/articles/reference/index.md)
> for more details.

### Main functions

#### `convert_to_parquet()`

This function takes one or more register SAS files and converts them to
a Parquet file or a Parquet dataset partitioned by year.

See
[`help(convert_to_parquet)`](https://dp-next.github.io/registers2parquet/reference/convert_to_parquet.md)
for more details.

The function requires two inputs:

- **path**: A character vector with path(s) to one or several files that
  should be converted.
- **output_path**: A character vector with the path to the directory
  where the Parquet file(s) should be written to.

If multiple files are given, the function looks for a year in the file
names to use as partitioning. The function also removes any duplicate
rows before saving the data.

The output of `convert_register_to_parquet()` is the character vector
given as input in `output_path`. This allows for easy integration into a
targets pipeline.

Even though the function doesn’t return the written Parquet register,
its creation is confirmed with a message in the R console.

The created Parquet files will be stored in a directory structure that
reflects the register name and a year partitioning if a year can be
determined from the file name(s). Below is shown an example of the input
and output for a collection of SAS files for the `bef` register:

#### Input: Register SAS files

    bef2018.sas7bdat
    bef2019.sas7bdat
    bef2020.sas7bdat
    bef2021.sas7bdat
    bef2022.sas7bdat
    December_2023/bef2022.sas7bdat
    December_2023/bef2023.sas7bdat

#### Output: Parquet files

    bef/
    ├── year=2018/
    │   └── part-0.parquet
    ├── year=2019/
    │   └── part-0.parquet
    ├── year=2020/
    │   └── part-0.parquet
    ├── year=2021/
    │   └── part-0.parquet
    ├── year=2022/
    │   └── part-0.parquet
    └── year=2023/
        └── part-0.parquet

As shown above, the Parquet files will be stored in a directory named
after the register (e.g., `bef/`), with subdirectories for each year
(e.g., `year=2018/`, `year=2019/`, etc.) if the year can be determined
from the file name. Each year directory contains a Parquet file
(`part-0.parquet`). This structure allows for efficient querying and
retrieval of data based on the year.

#### `read_register(register_name, project_id)`

Reads a Parquet register from the specified path and returns it as a
DuckDB table.

### Helper functions

#### `list_sas_registers(project_id)`

Lists all SAS files in a given directory. It returns a character vector
of file paths with the `.sas7bdat` extension at the given directory.

#### `list_parquet_registers(project_id)`

Lists all Parquet files in a given directory. It returns a character
vector of file paths with the `.parquet` or `.parq` extension at the
given directory.

## Expected flow

We expect the flow of using the `registers2parquet` package to convert
register SAS files to Parquet files will be as follows:

``` mermaid
flowchart TD

    identify_paths("Identify register path(s)<br>with helper functions")
    path[/"path<br>[Character vector]"/]
    output_path[/"output_path<br>[Character scalar]"/]
    convert_to_parquet("convert_to_parquet()")
    output[/"Output<br>[Character scalar]<br>Path to Parquet file(s)"/]


    %% Edges
    identify_paths -.-> path --> convert_to_parquet
    output_path --> convert_to_parquet
    convert_to_parquet --> output

    %% Styling
    style identify_paths fill:#FFFFFF, color:#000000, stroke-dasharray: 5 5
```

Figure 1: Flow of the expected flow using the
[`convert_to_parquet()`](https://dp-next.github.io/registers2parquet/reference/convert_to_parquet.md)
package to convert register SAS files to Parquet files.

We expect a flow of reading a Parquet register created by the
`registers2parquet` package into an R session to be as follows:

``` mermaid
flowchart TD

    project_id[/"project_id<br>[Character scalar]"/]
    path[/"path<br>[Character scalar]"/]

    read_register("read_register()")

    output[/"Output<br>[DuckDB table]"/]

    %% Edges
    path & project_id --> read_register --> output
```

Figure 2: Flow of the expected flow of reading a Parquet register that
was created with the `registers2parquet` package.
