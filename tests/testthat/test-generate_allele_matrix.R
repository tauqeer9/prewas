# replace_non_ATGC_with_N -----------------------------------------------------#
test_that("replace_non_ATGC_with_N() gives error when given invalid input", {
  # integer
  expect_error(replace_non_ATGC_with_N(1))

  # character
  expect_error(replace_non_ATGC_with_N("foo"))

  # factor
  expect_error(replace_non_ATGC_with_N(as.factor("foo")))
})

test_that("replace_non_ATGC_with_N() returns matrix when given valid input", {
  allele_mat <- matrix(c("A", "T", "*", NA), nrow = 3, ncol = 4)

  replace_results <- replace_non_ATGC_with_N(allele_mat)
  # Returns a matrix
  expect_true(methods::is(replace_results, "matrix"))

  # Replaces all NAs
  expect_equal(0, sum(is.na(replace_results)))

  # Replaces all starts
  expect_equal(0, sum(grepl(pattern = "[*]", x = replace_results)))

  # Replaces the correct number of NAs and *s
  expect_equal(6, sum(grepl(pattern = "N", x = replace_results)))
})

test_that("replace_non_ATGC_with_N() returns valid results when given indels", {
  allele_mat <- matrix(c("A", "ATTTTTGC", "*", NA), nrow = 3, ncol = 4)

  replace_results <- replace_non_ATGC_with_N(allele_mat)
  # Returns a matrix
  expect_true(methods::is(replace_results, "matrix"))

  # Replaces all NAs
  expect_equal(0, sum(is.na(replace_results)))

  # Replaces all starts
  expect_equal(0, sum(grepl(pattern = "[*]", x = replace_results)))

  # Replaces the correct number of NAs and *s
  expect_equal(6, sum(grepl(pattern = "N", x = replace_results)))

  # Does *not* replaces the insertion, ATTTTTGC
  expect_equal(3, sum(grepl(pattern = "ATTTTTGC", x = replace_results)))
})

# identify_variant_sites ------------------------------------------------------#
test_that("identify_variant_sites() returns correct rows when given valid input", {
  allele_mat <- matrix(c("A", "A", "A", "A", "C", "A"), nrow = 4, ncol = 3)
  rows_to_keep_log <- identify_variant_sites(allele_mat)
  expect_equal(c(TRUE, FALSE, TRUE, FALSE), rows_to_keep_log)
})

test_that("identify_variant_sites() gives error when given invalid input", {
  allele_mat <- as.data.frame(matrix(c("A", "A", "A", "A", "C", "A"),
                                     nrow = 4,
                                     ncol = 3))
  expect_error(identify_variant_sites(allele_mat))

  expect_error(identify_variant_sites("foo"))
})

test_that("identify_variant_sites() gives error if there are no variant sites", {
  allele_mat <- matrix(c("A", "A", "A", "A", "A", "A"), nrow = 4, ncol = 3)
  expect_error(identify_variant_sites(allele_mat))
})

# remove_invariant_sites ------------------------------------------------------#
test_that("remove_invariant_sites() removes the correct rows when given valid input", {
  allele_mat <- matrix(c("A", "A", "A", "A", "C", "A"), nrow = 4, ncol = 3)
  rows_to_keep_log <- identify_variant_sites(allele_mat)
  ref <- c("A", "T", "A", "T")
  alt <- c("C", "T", "C", "T")
  only_variant_mat <- remove_invariant_sites(mat = allele_mat,
                                             rows_to_keep = rows_to_keep_log,
                                             o_ref = ref,
                                             o_alt = alt,
                                             snpeff = NULL)
  expected_results <- matrix(c("A", "A", "C", "A", "A", "C"), nrow = 2)
  expect_equal(expected_results, only_variant_mat$mat)
  expect_equal(only_variant_mat$o_alt, c("C", "C"))
  expect_equal(only_variant_mat$o_ref, c("A", "A"))
  expect_null(only_variant_mat$snpeff)
})

test_that("remove_invariant_sites() gives errors when given invalide inputs", {
  expect_error(remove_invariant_sites("foo", "bar"))

  allele_mat <- matrix(c("A", "A", "A", "A", "C", "A"), nrow = 4, ncol = 3)
  rows_to_keep_log <- identify_variant_sites(allele_mat)

  # Invalid matrix
  expect_error(remove_invariant_sites(6, rows_to_keep_log))

  # Invalid logical vector
  expect_error(remove_invariant_sites(allele_mat, matrix(1:10, nrow = 2)))

  # Matrix too small
  expect_error(remove_invariant_sites(allele_mat[1, , drop = FALSE],
                                      rows_to_keep_log))

  # Logical vector too long
  expect_error(remove_invariant_sites(allele_mat, c(rows_to_keep_log,
                                                    rows_to_keep_log)))

  # Dataframe instead of matrix
  expect_error(remove_invariant_sites(as.data.frame(allele_mat),
                                      rows_to_keep_log))

})

# keep_only_variant_sites -----------------------------------------------------#
test_that("keep_only_variant_sites returns expected matrix when given valid input", {
  allele_mat <- matrix(c("A", "T", "A", "*", NA,
                         "A", "T", "A", "A", "A",
                         "A", "A", "T", "A", "T"), nrow = 5, ncol = 3)
  o_ref <- c("A", "T", "A", "A", "T")
  o_alt <- c("T", "A", "T", "T", "A")
  snpF <- NULL
  # TO DO make o_ref, o_alt, snpeff
  test_output <- keep_only_variant_sites(dna_mat = allele_mat,
                                         o_ref = o_ref,
                                         o_alt = o_alt,
                                         snpeff = snpF)
  expected_output <- matrix(c("T", "A", "N",
                              "T", "A", "A",
                              "A", "T", "T"), nrow = 3, ncol = 3)
  expect_equal(test_output$variant_only_dna_mat, expected_output)
})


test_that("keep_only_variant_sites errors when given invalid input", {
  allele_mat <- matrix(c("A", "T", "A", "*", NA,
                         "A", "T", "A", "A", "A",
                         "A", "A", "T", "A", "T"), nrow = 5, ncol = 3)
  o_ref <- c("A", "T", "A", "A", "T")
  o_alt <- c("T", "A", "T", "T", "A")
  snpF <- NULL
  # Wrong object type
  expect_error(keep_only_variant_sites(dna_mat = as.data.frame(allele_mat),
                                       o_ref = o_ref,
                                       o_alt = o_alt,
                                       snpeff = snpF))
  expect_error(keep_only_variant_sites(dna_mat = "allele_mat",
                                       o_ref = o_ref,
                                       o_alt = o_alt,
                                       snpeff = snpF))

  # Only invariant sites
  allele_mat <- matrix(rep("A", 100), nrow = 10)
  o_ref <- rep("A", 10)
  o_alt <- rep("T", 10)
  snpF <- NULL
  expect_error(keep_only_variant_sites(dna_mat = allele_mat,
                                       o_ref = o_ref,
                                       o_alt = o_alt,
                                       snpeff = snpF))
})
