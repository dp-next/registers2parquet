## R CMD check results

0 errors | 0 warnings | 1 note

❯ checking CRAN incoming feasibility... [4s/53s] NOTE Maintainer: ‘Signe
Kirk Brødbæk <signekb@clin.au.dk>’

  Days since last update: 5

This release fixes critical bugs we found when we used the package on very large
files on a Windows server. We expect future updates to be less frequent.

## Testing

- We ran this locally on MacOS and Ubuntu, as well as through GitHub
  Action workflows on MacOS, Ubuntu, and Windows (using the release R
  version). We ran devel and oldrel checks on the Ubuntu GitHub Action.
- We also ran on CRAN's win-builder.
