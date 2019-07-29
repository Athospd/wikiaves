
test_that("wa_get_taxons_json works", {

  result1 <- wikiaves:::wa_get_taxons_json("megascops choliba")

  expect_equal(nrow(result1), 1)
  expect_equal(ncol(result1), 7)
  expect_equal(names(result1), c("id", "wid", "label", "nome", "sp", "tax", "class", "ds"))
  expect_equal(class(result1), "data.frame")

  result2 <- wikiaves:::wa_get_taxons_json("megascops c")
  expect_identical(result1, result2)

  result3 <- wikiaves:::wa_get_taxons_json("megascops")
  expect_equal(nrow(result3), 7)
  expect_equal(ncol(result1), ncol(result3))
  expect_equal(names(result1), names(ncol(result3)))
  expect_equal(class(result1), class(ncol(result3)))

})

test_that("wa_get_registros_json works", {
  one_page_species_metadata <- wikiaves:::wa_get_registros_json(id = 10513)
  expect_equal(class(one_page_species_metadata), c("tbl_df", "tbl", "data.frame"))
  expect_equal(ncol(one_page_species_metadata), 24)

  non_existing_page_species_metadata <- wikiaves:::wa_get_registros_json(id = 10513, p = 10000)
  expect_equal(ncol(non_existing_page_species_metadata), 3)
  expect_equal(nrow(non_existing_page_species_metadata), 0)
})

test_that("wa_get_registros_json_n works", {
  n <- wikiaves:::wa_get_registros_json_n(id = 10513)
  expect_equal(class(n), "numeric")
  expect_equal(length(n), 1)
  expect_gt(n, 100)


  expect_success(wikiaves:::wa_get_registros_json_n(id = 24325535))
  expect_equal(wikiaves:::wa_get_registros_json_n(1501), 0)
})

test_that("wa_get_registers_by_id works", {
  all_pages_species_metadata <- wikiaves:::wa_get_registers_by_id(id = 10513)
  n <- wikiaves:::wa_get_registros_json_n(id = 10513)
  expect_equal(nrow(all_pages_species_metadata), n)

})

test_that("wa_metadata works", {
  terms = c("megascops choliba", "strix hylophila", "pulsatrix koeniswaldiana", "megascops atricapilla", "glaucidium minutissimum")
  short_terms = c("megascops ch", "strix h", "pulsatrix", "megascops", "glaucid")

  metadata <- wikiaves::wa_metadata(c("Querula purpurata", "Cotinga cayana"))
  expect_equal(class(metadata), c("tbl_df", "tbl", "data.frame"))
  expect_equal(ncol(metadata), 35)

  metadata <- wikiaves::wa_metadata(c("Querula purpurata", "Cotin"))

})


test_that("wa_download works", {

  dir_1 <- tempdir()
  metadata_com_download <- wikiaves::wa_metadata(c("Cotinga cayana"), download = TRUE, path = dir_1)
  dir_2 <- tempdir()
  metadata_com_download_encadeado <- wikiaves::wa_metadata(c("Cotinga cayana"), download = FALSE) %>% wikiaves::wa_download( dir_2)
  expect_equal(list.files(dir_1), list.files(dir_2))
  expect_equal(metadata_com_download_encadeado, metadata_com_download)
})
