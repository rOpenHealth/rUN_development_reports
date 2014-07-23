rUN_development_reports
=======================

R integration with the UN development programme API

Info
====

This package supports querying the data from the [UNDP Human Development Reports](http://hdr.undp.org/en/data). There are twelve tables in this report covering the following areas:

* Human Development Index and its Components
* Human Development Index Trends
* Inequality-Adjusted Human Development
* Gender Inequality Index
* Multidimensional Poverty Index
* Command Over Resources
* Health
* Education
* Social Integration
* International Trade Flows of Goods and Services
* International Capital Flows and Migrations
* Innovation and Technolog
* Environment
* Population

The UNdp API is a [Socrata Open Data API](http://www.socrata.com/products/open-data-api/).  This package exposes the full [SODA API](http://dev.socrata.com/docs/queries.html) so you can subset and filter your queries on the server-side.  Alternatively you can download the whole dataset and process them entirely in R.

The SODA interaction is largely handled by the [RSocrata](https://github.com/Chicago/RSocrata) package.  However, I had to make some changes to the RSocrata package to allow for missing columns of data.  This required copies of the RSocrata functions being held in this repository.  If the [pull request](https://github.com/Chicago/RSocrata/pull/3) for the bug fix is accepted, I will remove this section and call the [CRAN package](http://cran.r-project.org/web/packages/RSocrata/index.html) directly.

The package provides partial matching for table names and record type, as well as conveniance arguments for the country field and the SODA queries `where`, `select`, `order` and `q`.

The main user fetch function is `fetch_undp_table`.  This fetches one of the tables from the API and allows for selecting individual columns, as well as subsets of data and fuzzy matching.

Note that the UNDP will soon be releasing the 2014 Human development report and this may have some breaking changes in the API


Examples
========

## 1. Find the top 10 highest ranking countries, according to the Human development Index

``` R
> df <- fetch_undp_table(table = "1: Human", 
                        select = c("name", "abbreviation", "_2012_hdi_value"),
                        where = "_2012_hdi_rank<11")

> df
            name X_2012_hdi_value abbreviation
1         Norway            0.955          NOR
2      Australia            0.938          AUS
3  United States            0.937          USA
4    Netherlands            0.921          NLD
5        Germany            0.920          DEU
6    New Zealand            0.919          NZL
7        Ireland            0.916          IRL
8         Sweden            0.916          SWE
9    Switzerland            0.913          CHE
10         Japan            0.912          JPN
```

## 2. Comparisons of healthcare spending, HDI rank, infant and adult mortality

``` R
> df1 <- fetch_undp_table(table = "6: Command Over Resources", 
                        select = c("name", "_2000_health_of_gdp", "_2010_health_of_gdp"))
> df2 <- fetch_undp_table(table = "7: Health")

> combined <- merge(df1, df2)
> comps <- data.matrix(combined[,c("X_2010_health_of_gdp", "X_2012_hdi_rank", 
                                   "X_2010_infant_mortality_rate", 
                                   "X_2009_adult_mortality_rate_female")])
> cor(comps,use = "complete.obs")
                                   X_2010_health_of_gdp X_2012_hdi_rank X_2010_infant_mortality_rate X_2009_adult_mortality_rate_female
X_2010_health_of_gdp                          1.0000000      -0.5447932                   -0.4702117                         -0.3474259
X_2012_hdi_rank                              -0.5447932       1.0000000                    0.8655277                          0.7789660
X_2010_infant_mortality_rate                 -0.4702117       0.8655277                    1.0000000                          0.8414263
X_2009_adult_mortality_rate_female           -0.3474259       0.7789660                    0.8414263                          1.0000000

```

## 3. Set the order of returned results

``` R
> order_asc <- fetch_undp_table(x4code = "wxub-qc5k", where = "_2012_hdi_rank<50", 
                                  select = c("name", "abbreviation", "_2012_hdi_value"),
                                  order = "name")
> order_desc <- fetch_undp_table(x4code = "wxub-qc5k", where = "_2012_hdi_rank<50", 
                                   select = c("name", "abbreviation", "_2012_hdi_value"),
                                   order = "-name")
> head(order_asc)
       name X_2012_hdi_value abbreviation
1   Andorra            0.846          AND
2 Argentina            0.811          ARG
3 Australia            0.938          AUS
4   Austria            0.895          AUT
5   Bahamas            0.794          BHS
6   Bahrain            0.796          BHR

> head(order_desc)
                  name X_2012_hdi_value abbreviation
1        United States            0.937          USA
2       United Kingdom            0.875          GBR
3 United Arab Emirates            0.818          ARE
4          Switzerland            0.913          CHE
5               Sweden            0.916          SWE
6                Spain            0.885          ESP

```

## 4. Download all data tables and store in a list

```
undp_tables <- all_undp_tables()

```

Any errors will be represented as an error string

# Issues

If you have any issues or suggestions, feel free to email daspringate@@gmail.com or to fork and make pull requests. 

