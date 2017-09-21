context("hec_file")

test_that("hec_file no file errors correctly", {
  non_existing_dir <- "this-dir-doesnt-exist/"
  non_existing_file <- "this-file-doesnt-exist.hdf"
  real_dir <- "raw-data-for-test/"
  
  expect_error(hec_file(non_existing_file), 
               "file: 'this-file-doesnt-exist.hdf' was not found in '.'")
  expect_error(hec_file(non_existing_dir))
  expect_error(hec_file(real_dir, plan_numbers = c(20)))
})
