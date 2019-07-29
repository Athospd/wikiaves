
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wikiaves

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/wikiaves)](https://CRAN.R-project.org/package=wikiaves)
[![Travis build
status](https://travis-ci.org/Athospd/wikiaves.svg?branch=master)](https://travis-ci.org/Athospd/wikiaves)
[![Codecov test
coverage](https://codecov.io/gh/Athospd/wikiaves/branch/master/graph/badge.svg)](https://codecov.io/gh/Athospd/wikiaves?branch=master)
<!-- badges: end -->

Non-official R interface for [wikiaves](wikiaves.com.br) API, that
retrieve sounds from its repository (no images supported yet). The goal
of wikiaves R package is to aid analysis and data-driven projects.

**Attention** This package is on a VERY EARLY development stage. Expect
things to change a lot\! And any help is wellcome =).

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("Athospd/wikiaves")
```

The released version of wikiaves from [CRAN](https://CRAN.R-project.org)
will be available soon.

## Example

This is a basic example which shows you how to fetch metadata from
registers in wikiaves:

``` r
library(wikiaves)
library(dplyr)
# fetching metadata in a tidy tibble
birds_metadata <- wa_metadata(c("Querula purpurata", "Cotin"))
#> IDs found from terms:
#> id = 11387 (from term 'Querula purpurata')
#> id = 11371 (from term 'Cotin')
#> id = 11369 (from term 'Cotin')
#> id = 11368 (from term 'Cotin')
#> id = 11382 (from term 'Cotin')
#> id = 1501 (from term 'Cotin')
#> id = 1508 (from term 'Cotin')
#> id = 1980 (from term 'Cotin')
#> id = 11370 (from term 'Cotin')
#> id = 11385 (from term 'Cotin')
#> id = 11381 (from term 'Cotin')
#> id = 11384 (from term 'Cotin')
#> id = 11367 (from term 'Cotin')
#> id = 11437 (from term 'Cotin')
#> id = 11388 (from term 'Cotin')
#> id = 11386 (from term 'Cotin')
#> Id 11371 has 2 registers.
#> Id 11369 has 3 registers.
#> Id 11368 has 1 registers.
#> Id 11382 has 2 registers.
#> Id 1501 has 0 registers.
#> Id 1508 has 0 registers.
#> Id 1980 has 0 registers.
#> Id 11370 has 2 registers.
#> Id 11385 has 14 registers.
#> Id 11381 has 16 registers.
#> Id 11384 has 12 registers.
#> Id 11367 has 2 registers.
#> Id 11437 has 2 registers.
#> Id 11388 has 4 registers.
#> Id 11386 has 0 registers.
#> 130 registers fetched from 16 distinct IDs.
```

### Downloading…

This is smart enough to download non-existing or zero sized files only.

``` r
# download mp3
my_mp3_folder <- tempdir()
birds_metadata %>% wa_download(my_mp3_folder)
#> MP3s will be stored in /tmp/RtmpPfBzAj.
```

### MP3 files in your local machine with names ready to analytics.

``` r
head(list.files(my_mp3_folder))
#> [1] "Conioptilon-mcilhennyi-1019456.mp3"
#> [2] "Conioptilon-mcilhennyi-1021089.mp3"
#> [3] "Conioptilon-mcilhennyi-1064304.mp3"
#> [4] "Conioptilon-mcilhennyi-1122948.mp3"
#> [5] "Conioptilon-mcilhennyi-1342891.mp3"
#> [6] "Conioptilon-mcilhennyi-2061041.mp3"
```

### Metadata in a tidy tibble.

``` r
glimpse(birds_metadata)
#> Observations: 130
#> Variables: 35
#> $ term           <chr> "Querula purpurata", "Querula purpurata", "Querul…
#> $ id             <chr> "11387", "11387", "11387", "11387", "11387", "113…
#> $ wid            <chr> "anambe-una", "anambe-una", "anambe-una", "anambe…
#> $ label          <chr> "Querula purpurata", "Querula purpurata", "Querul…
#> $ nome           <chr> "anambé-una", "anambé-una", "anambé-una", "anambé…
#> $ sp             <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ tax            <chr> "Espécie", "Espécie", "Espécie", "Espécie", "Espé…
#> $ class          <chr> "sp", "sp", "sp", "sp", "sp", "sp", "sp", "sp", "…
#> $ ds             <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1", "1",…
#> $ titulo         <chr> "Sons de anambé-una (<i>Querula purpurata</i>)", …
#> $ link           <chr> "registros.php?tm=s&t=s&s=11387&o=mp&p=1", "regis…
#> $ total          <chr> "66", "66", "66", "66", "66", "66", "66", "66", "…
#> $ id1            <int> 63502, 581487, 177088, 115628, 2137891, 1697896, …
#> $ tipo           <chr> "S", "S", "S", "S", "S", "S", "S", "S", "S", "S",…
#> $ id_usuario     <chr> "", "", "", "", "", "", "", "", "", "", "", "", "…
#> $ sp.id          <chr> "11387", "11387", "11387", "11387", "11387", "113…
#> $ sp.nome        <chr> "Querula purpurata", "Querula purpurata", "Querul…
#> $ sp.nvt         <chr> "anambé-una", "anambé-una", "anambé-una", "anambé…
#> $ sp.idwiki      <chr> "anambe-una", "anambe-una", "anambe-una", "anambe…
#> $ autor          <chr> "Thiago V. V. Costa", "Eduardo Patrial", "Bruno R…
#> $ por            <chr> "Por", "Por", "Por", "Por", "Por", "Por", "Por", …
#> $ perfil         <chr> "tvvc", "Patrial", "brunoornitologia", "kurazooka…
#> $ data           <chr> "14/04/2009", "12/02/2012", "12/02/2010", "03/03/…
#> $ is_questionada <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, …
#> $ local          <chr> "Eirunepé/AM", "Nova Canaã do Norte/MT", "Santa B…
#> $ idMunicipio    <int> 1301407, 5106216, 1506351, 1600279, 1717503, 1507…
#> $ coms           <int> 1, 1, 2, 1, 1, 0, 2, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1…
#> $ likes          <int> 17, 10, 3, 3, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ vis            <int> 591, 115, 45, 19, 8, 2, 12, 1, 18, 28, 34, 2, 5, …
#> $ grande         <chr> "F", "F", "F", "F", "F", "F", "F", "F", "F", "F",…
#> $ enviado        <chr> "0 minutos", "0 minutos", "0 minutos", "0 minutos…
#> $ link1          <chr> "https://s3.amazonaws.com/media.wikiaves.com.br/r…
#> $ dura           <chr> "15s", "28s", "1m18s", "21s", "40s", "22s", "18s"…
#> $ mp3_name       <chr> "Querula-purpurata-63502.mp3", "Querula-purpurata…
#> $ mp3_link       <chr> "https://s3.amazonaws.com/media.wikiaves.com.br/r…
```

## Acknowledgement

This package is part of a larger project called **“Automatic acoustic
detectors of night bird species in their natural biome”**, oriented by
Professor Doctor Linilson Padovese and co-oriented by Professor Doctor
Paulo Hubert. This project aims to build machine learning systems in the
context of bird identification.

## Contributor Code of Conduct

Please note that the ‘wikiaves’ project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.
