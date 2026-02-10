# Simulate an example register

The data is simulated using
[`osdc::simulate_registers()`](https://steno-aarhus.github.io/osdc/reference/simulate_registers.html).
It's used in vignettes and tests.

## Usage

``` r
simulate_register(register, year = "", n = 1000)
```

## Arguments

- register:

  Name of the register. Has to be a register accepted by
  osdc::simulate_registers().

- year:

  A character vector of year suffixes appended to the register name to
  form the list element names (e.g., `"2020"`, `"1999_1"`, or `""` for
  no suffix).

- n:

  Number of rows to simulate per year.

## Value

A named list of tibble(s) with names in the format `{register}_{year}`.

## Examples

``` r
simulate_register(register = "kontakter", year = c("1999", "2000"))
#> $kontakter_1999
#> # A tibble: 1,000 × 4
#>    cpr          dw_ek_kontakt      dato_start hovedspeciale_ans    
#>    <chr>        <chr>              <chr>      <chr>                
#>  1 108684730664 920166254345774467 20170316   Fysio- og ergoterapi 
#>  2 982144017357 075972782062569784 20081030   Thoraxkirurgi        
#>  3 672580814975 176536283003603061 19781226   Klinisk immunologi   
#>  4 439008110445 581624294965046227 20040706   Akut medicin         
#>  5 489714666740 814210282344580857 20160613   Karkirurgi           
#>  6 155331797020 393885735973313484 20001231   Nefrologi            
#>  7 777951655096 836179506546686729 20250325   Diagnostisk radiologi
#>  8 167007504860 814175436846538799 19961124   Pædiatri             
#>  9 132473802596 508133593881487375 19970403   Klinisk immunologi   
#> 10 876820784981 325077063891132755 19990709   Geriatri             
#> # ℹ 990 more rows
#> 
#> $kontakter_2000
#> # A tibble: 1,000 × 4
#>    cpr          dw_ek_kontakt      dato_start hovedspeciale_ans    
#>    <chr>        <chr>              <chr>      <chr>                
#>  1 108684730664 920166254345774467 20170316   Fysio- og ergoterapi 
#>  2 982144017357 075972782062569784 20081030   Thoraxkirurgi        
#>  3 672580814975 176536283003603061 19781226   Klinisk immunologi   
#>  4 439008110445 581624294965046227 20040706   Akut medicin         
#>  5 489714666740 814210282344580857 20160613   Karkirurgi           
#>  6 155331797020 393885735973313484 20001231   Nefrologi            
#>  7 777951655096 836179506546686729 20250325   Diagnostisk radiologi
#>  8 167007504860 814175436846538799 19961124   Pædiatri             
#>  9 132473802596 508133593881487375 19970403   Klinisk immunologi   
#> 10 876820784981 325077063891132755 19990709   Geriatri             
#> # ℹ 990 more rows
#> 
```
