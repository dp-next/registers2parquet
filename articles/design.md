# Design

## Conversion process

    bef2018.sas7bdat
    bef2019.sas7bdat
    bef2020.sas7bdat
    bef2021.sas7bdat
    bef2022.sas7bdat
    December_2023/bef2022.sas7bdat
    December_2023/bef2023.sas7bdat

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

## Visual representation

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
```
