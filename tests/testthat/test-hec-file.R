context("hec_file")

test_that("hec_file no file errors correctly", {
  non_existing_dir <- "this-dir-doesnt-exist/"
  non_existing_file <- "this-file-doesnt-exist.hdf"
  real_dir <- "raw-data-for-test/"
  
  expect_error(hec_file(non_existing_file), 
               "file: 'this-file-doesnt-exist.hdf' was not found in '.'")
  expect_error(hec_file(non_existing_dir))
  expect_error(hec_file(real_dir, plan_numbers = c(20)))
  expect_error(hec_file())
})


test_that("hec_file produces messages", {
  real_dir <- "raw-data-for-test/"
  
  expect_message(hec_file(real_dir))
})

test_that("hec_file reads correct number of hdf files", {
  file_from_dir_input <- hec_file("raw-data-for-test/") #dir has a non hdf in there as well
  file_from_direct_input <- hec_file("empty_hdf.p50.hdf")
  
  expect_equal(length(file_from_dir_input), 1)
  expect_equal(length(file_from_direct_input), 1)
})