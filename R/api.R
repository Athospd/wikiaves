
#' Interface to `getTaxonsJSON` from wikiaves.
#'
#' @param term character vector with the terms to be searched by wikiaves API. Can be a full species specification or just part of it, eg. c("megascops choliba", "strix h").
wa_get_taxons_json <- function(term) {
  jsonlite::fromJSON(URLencode(glue::glue("https://www.wikiaves.com.br/getTaxonsJSON.php?term={term}")))
}

#' Interface to `getRegistrosJSON` from wikiaves
#'
#' @param id integer. Wikiaves' id of a species.
#' @param p integer. The page number to fetch the results.
#' @param tm sound ("s") or photo ("f").
#' @param t unkown yet.
wa_get_registros_json <- function(
  id,
  p = 1,
  tm = c("s", "f"),
  t = "s"
) {
  jsonlite::fromJSON(glue::glue("https://www.wikiaves.com.br/getRegistrosJSON.php?tm={tm[1]}&t={t}&s={id}&o=mp&p={p}")) %>%
    purrr::transpose() %>%
    purrr::map_df(purrr::simplify) %>%
    tidyr::unnest() %>%
    dplyr::mutate(itens = purrr::map(itens, as.data.frame, stringsAsFactors = FALSE)) %>%
    tidyr::unnest()
}



#' Figure out the total count of registers from a given call from `wa_get_registros_json()`
#'
#' @param id integer. Wikiaves' id of a species.
#' @param tm sound ("s") or photo ("f")
wa_get_registros_json_n <- function(id, tm = c("s", "f")) {
  result <- wa_get_registros_json(
    id = id,
    p = 1,
    tm = tm
  )
  n <- as.numeric(result$total[1])
  if(is.na(n)) n <- 0
  return(n)
}


#' Fetch all pages from `getRegistrosJSON` results.
#'
#' @param id integer. Wikiaves' id of a species.
#' @param tm sound ("s") or photo ("f")
#' @param sys_sleep numeric. A time offset to avoid exploding wikiaves' server
wa_get_registers_by_id <- function(
  id,
  tm = c("s", "f"),
  sys_sleep = 0.01
) {
  total_registers <- wa_get_registros_json_n(id)
  pages <- ceiling(total_registers / 18)

  if(pages <= 1) {
    cat(crayon::red(glue::glue("Id {id} has {total_registers} registers.\n\n")))
  }
  if(total_registers == 0) {
    return(tibble::tibble(id = as.integer(id)))
  }

  pb <- progress::progress_bar$new(total = pages, format = glue::glue("Id {id} has {total_registers} registers. Fetching metadata [:bar] page :current of :total" ), clear = FALSE)

  registers <- seq(pages) %>%
    purrr::map_dfr(~{
      pb$tick()
      Sys.sleep(sys_sleep)
      wa_get_registros_json(id, p = .x, tm = tm, t = "s")
    })

  return(registers)
}



#' Main function. Get metadata from wikiaves from a set of terms.
#'
#' @param term character vector with the terms to be searched by wikiaves API. Can be a full species specification or just part of it, eg. c("megascops choliba", "strix h").
#' @param tm sound ("s") or photo ("f")
#' @param verbose boolean. Should it give extra information during the process? Default to TRUE.
#' @param download boolean. Should the files be downloaded? Default to FALSE. You can choose to download later by using wa_download() function.
#' @param path character. A string specifying the place to store the MP3 files if download is set to TRUE.
#' @param mp3_file_name character. A 'glue'-like format string with the pattern of the names of the mp3 files.
#' @param parallel integer. Number of cores for parallel processing.
#' @param metadata_sys_sleep numeric. A time offset to avoid exploding wikiaves' server.
#' @param download_sys_sleep numeric. A time offset to avoid exploding wikiaves' server.
#' @param force boolean. If mp3 exists, should it be overwritten? If set to FALSE it will download non-existing or zero sized files only. Default to FALSE.
#'
#' @export
wa_metadata <- function(
  term,
  tm = c("s", "f"),
  verbose = TRUE,
  download = FALSE,
  path = getwd(),
  mp3_file_name = "{label}-{id1}.mp3",
  parallel = 1,
  metadata_sys_sleep = 0.1,
  download_sys_sleep = 0.0001,
  force = FALSE
) {
  wa_metadata <- tibble::tibble(
    term = term
  ) %>%
    dplyr::mutate(
      taxonomy = purrr::map(term, wa_get_taxons_json)
    ) %>%
    tidyr::unnest() %>%
    {
      if(verbose) cat("IDs found from terms:\n")
      return(.)
    } %>%
    dplyr::distinct(id, .keep_all = TRUE) %>%
    dplyr::mutate(
      verbose = purrr::map2(term, id, ~{
        if(verbose) {
          cat(glue::glue("id = {.y} (from term '{.x}')\n"))
          cat("\n")
        }
        return(NULL)
      }),
      registers = purrr::map(id, ~{
        wa_get_registers_by_id(.x, tm = tm, sys_sleep = metadata_sys_sleep)
      })
    ) %>%
    dplyr::select(-verbose) %>%
    tidyr::unnest() %>%
    tidyr::unnest()  %>%
    dplyr::mutate(
      mp3_name = glue::glue(mp3_file_name) %>% stringr::str_replace(" ", "-"),
      mp3_link = link1 %>% stringr::str_replace("jpg$", "mp3") %>% stringr::str_replace("#_", "_")
    )

  if(verbose) {
    cat(nrow(wa_metadata), "registers fetched from", dplyr::n_distinct(wa_metadata$id), "distinct IDs.\n")
  }

  if(download) {
    wa_download(wa_metadata, path = path, verbose = verbose, sys_sleep = download_sys_sleep, force = force)
  }

  return(wa_metadata)
}


#' Download MP3 files listed in a data.frame wikiaves metadata.
#'
#' @param .wa_metadata a data.frame. Usualy the output from wa_metadata(), but it need just an mp3_link and an mp3_name columns.
#'
#' @return invisible .wa_metadata
#'
#' @export
wa_download <- function(.wa_metadata, path = getwd(), verbose = TRUE, sys_sleep = 0.0001, force = FALSE) {
  if(verbose) cat(glue::glue("\nMP3s will be stored in {normalizePath(path)}.\n\n"))
  pb <- progress::progress_bar$new(total = nrow(.wa_metadata), format = glue::glue("Downloading mp3 files [:bar] :current of :total (:elapsed)"), clear = FALSE)

  purrr::walk2(.wa_metadata$mp3_link, .wa_metadata$mp3_name, ~{
    pb$tick()
    Sys.sleep(sys_sleep)
    file_path <- glue::glue("{path}/{.y}")

    if(!is.na(.x) & (force | !file.exists(file_path) | dplyr::near(file.size(file_path), 0))) {
      httr::GET(.x, httr::write_disk(file_path, overwrite = TRUE))
    }
  })

  return(invisible(.wa_metadata))
}
