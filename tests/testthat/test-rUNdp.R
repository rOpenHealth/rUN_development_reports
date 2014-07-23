context("fetch_undp_table functionality")


test_that("Partial matching works", {
    expect_that(class(fetch_undp_table(table = "4: Gender")), equals("data.frame"))
    expect_that(class(fetch_undp_table(table = "6")), equals("data.frame"))
    expect_that(class(fetch_undp_table(table = "No matching table", x4code = "wxub-qc5k")), 
                equals("data.frame"))
    expect_that(fetch_undp_table(table = "No matching table"), throws_error())
    
    expect_that(class(fetch_undp_table(table = "6", type = "Quart")), equals("data.frame"))
    expect_that(fetch_undp_table(table = "1:", type = "Fifedom"), throws_error())
})

test_that("Column selector works", {
    expect_that(nrow(fetch_undp_table(x4code = "wxub-qc5k", country = "Germany")), equals(1))
    expect_that(nrow(fetch_undp_table(x4code = "wxub-qc5k", name = "Germany")), equals(1))
    expect_that(nrow(fetch_undp_table(x4code = "wxub-qc5k", abbreviation = "AFG")), equals(1))
    expect_that(nrow(fetch_undp_table(x4code = "wxub-qc5k", name = "Hobbiton")), equals(0))
})


test_that("Socrata API works", {
    select_test <- fetch_undp_table(x4code = "wxub-qc5k", 
                                    select = c("name", "abbreviation", "_2012_hdi_value"))
    where_test <- fetch_undp_table(x4code = "wxub-qc5k", where = "_2012_hdi_rank<50")
    order_asc <- fetch_undp_table(x4code = "wxub-qc5k", where = "_2012_hdi_rank<50", 
                                  select = c("name", "abbreviation", "_2012_hdi_value"),
                                  order = "name")
    order_desc <- fetch_undp_table(x4code = "wxub-qc5k", where = "_2012_hdi_rank<50", 
                                   select = c("name", "abbreviation", "_2012_hdi_value"),
                                   order = "-name")
    q_test  <- fetch_undp_table(x4code = "wxub-qc5k", q = "Congo")
    
    expect_that(names(select_test), equals(c("name", "X_2012_hdi_value", "abbreviation")))
    expect_that(all(as.numeric(where_test$X_2012_hdi_rank) < 50), is_true())
    expect_that(all(order_desc$name == sort(order_desc$name,decreasing=TRUE)), is_true())
    expect_that(all(order_asc$name == sort(order_asc$name)), is_true())
    expect_that(q_test$abbreviation, equals(c("COG", "COD")))
})
