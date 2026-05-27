@_default:
    just --list --unsorted

# Run all recipes
run-all: cleanup install-deps format-all check-spelling check-urls check-code test install-package build-docs check-cran

# Format Markdown and R code
format-all: format-md format-r

# Install package dependencies
install-deps:
  #!/usr/bin/env Rscript
  pak::pak(
    dependencies = c(
      "all"
    ),
    ask = FALSE
  )
  pak::pak(c("styler", "spelling", "urlchecker", "devtools", "usethis"))

# Install the pre-commit hooks
install-precommit:
    # Install pre-commit hooks
    uvx pre-commit install
    # Run pre-commit hooks on all files
    uvx pre-commit run --all-files
    # Update versions of pre-commit hooks
    uvx pre-commit autoupdate

# Check spelling using devtools and typos package
check-spelling: _check-spelling-devtools _check-spelling-typos

# Check the spelling using devtools (CRAN-based)
@_check-spelling-devtools:
  #!/usr/bin/env Rscript
  devtools::spell_check()

# Check the spelling using typos package
@_check-spelling-typos:
  uvx typos .

# Update wordlist
update-wordlist:
  #!/usr/bin/env Rscript
  spelling::update_wordlist()

# Check all URLs in the package
check-urls: _check-urls-cran _check-urls-lychee

# Check URLs based on CRAN requirements
@_check-urls-cran:
  #!/usr/bin/env Rscript
  urlchecker::url_check()

# Install https://github.com/lycheeverse/lychee#installation
# Check URLs using lychee tool
@_check-urls-lychee:
  lychee . --verbose

# Style all R code in the package
format-r: _format-r-air _format-r-styler

# Format R code using Air (better than styler but can't do Quarto files yet)
@_format-r-air:
  air format .

# Format R code using styler (which formats Quarto files)
@_format-r-styler:
  #!/usr/bin/env Rscript
  styler::style_pkg()

# Format Markdown files
format-md:
  uvx rumdl fmt --silent

# Run the package tests
test:
  #!/usr/bin/env Rscript
  devtools::test()

# From https://jarl.etiennebacher.com/#installation
# Lint R code for any potential issues
check-code:
  jarl check .

# Run local CRAN checks
check-cran:
  #!/usr/bin/env Rscript
  devtools::check(error_on = "note")

# Build all documentation
build-docs: _build-rd _build-website _build-readme

# Build the Rd documentation files
@_build-rd:
  #!/usr/bin/env Rscript
  devtools::document()

# Build the pkgdown website
@_build-website:
  #!/usr/bin/env Rscript
  pkgdown::build_site(quiet = FALSE)

# Re-build the README file from the Quarto version
@_build-readme:
  uvx --from quarto quarto render README.qmd --to gfm

# Preview website locally
preview-website:
  #!/usr/bin/env Rscript
  pkgdown::preview_site()

# Install the package itself
install-package:
  #!/usr/bin/env Rscript
  devtools::install()

# Clean up auto-generated files
cleanup: _cleanup-vignettes _clean-pkgdown

# Clean up generated HTML and R files from vignettes
@_cleanup-vignettes:
  rm -f vignettes/*.R vignettes/*.html vignettes/articles/*.R vignettes/articles/*.html

# Clean up pkgdown website files
@_clean-pkgdown:
  #!/usr/bin/env Rscript
  pkgdown::clean_site()

# List all TODO items in the repository
list-todos:
  grep -R -n --exclude="justfile" --exclude-dir="docs/deps" --exclude="*.json" --exclude="*.html" "TODO" *
