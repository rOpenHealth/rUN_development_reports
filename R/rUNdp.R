
#' Function returning the socrata 4x4 codes matching the different datasets
#' 
#' This uses match.arg to do partial matching on the endpoint names
#' 
#' @param table_name Character string to match the table names in the database
#' @return Character string of a socrata 4x4 code
.api_endpoints <- function(table_name){
    endpoints <- list("1: Human Development Index and its Components" = "myer-egms",
                      "2: Human Development Index Trends" = "y8j2-3vi9",
                      "3: Inequality-Adjusted Human Development Index" = "n8fa-gx39",
                      "4: Gender Inequality Index" = "ku9i-8fxp",
                      "5: Gender related Development Index" = "me25-gsuv",
                      "6: Multidimensional Poverty Index" = "frx9-rb5i",
                      "7: Multidimensional Poverty Index - changes over time for select countries" = "263u-f92z",
                      "8: Command Over Resources" = "ti85-2nvi",
                      "9: Health - Children and Youth" = "d27x-j4an",
                      "10: Adult Health and Health Expenditure" = "qdu3-trb6",
                      "11: Education"  = "xn26-t7qa",
                      "12: Command over and allocation of resources" = "3rcm-zfpk",
                      "13: Social Competencies" = "5kdi-xutn",
                      "14: Personal Insecurity" = "qie2-6sik",
                      "15: International Integration" = "2g3j-ecrk",
                      "16: Environment" = "sf29-qtcx",
                      "17: Population trends" = "3vja-izgd",
                      "18: Supplementary indicators: Perceptions of wellbeing" = "p79w-icq5")
    endpoints[[match.arg(table_name, names(endpoints))]]
}


#' Returns the matched api_type for the argument
#' 
#' Allows for partial matching and laziness of typing!
#' 
#' @param type Character one of c("Quartile", "Ranked Country", "Region", "Unranked Country", 
#' "World"). Partial matches allowed.
#' @return Character
.api_types <- function(type = NULL){
    types <- c("Quartile", "Ranked Country", "Region", "Unranked Country", "World")
    if(!is.null(type)){
        type <- match.arg(type, types)
    }
    type
}


#' Internal function to parse an order string depending on whether or not it is ascending
#' 
#' Prefix the string with a "-" to return a descending parameter
#' @param s character
#' @return character with ascending/descending flag
.parse_order <- function(s){
    if(is.null(s)) return(s)
    if(length(grep("^-", s))){
        paste(substr(s, 2, nchar(s)), "desc", sep = "%20")
    } else  paste(s, "asc", sep = "%20")
}

fetch_undp_table <- function(table = "1: Human Development Index and its Components", x4code = NULL,
                             country = NULL, type = NULL, 
                             select = NULL, where = NULL, order = NULL, q = NULL, 
                             query_string_only = FALSE, ...){
    
    extra_args <- list(...)
    api_url <- "http://data.undp.org/resource/"
    type <- .api_types(type)
    order <- .parse_order(order)
    if(!is.null(select)) select <- paste(select, collapse = ",")
    if(is.null(x4code)){
        table_url <- paste0(api_url, .api_endpoints(table), ".json")    
    } else table_url <- paste0(api_url, x4code, ".json")
    
    api_args <- list(name = country, type = type, 
                     "$select" = select, "$where" = where, "$order" = order, "$q" = q)
    api_args <- api_args[sapply(api_args, function(x) !is.null(x))]
    api_args <- c(api_args, extra_args)
    api_args <- paste(names(api_args),api_args, sep = "=", collapse = "&")
    if(nchar(api_args)){
        query <- paste(table_url, api_args, sep = "?")
    } else query <- table_url
    
    if(query_string_only){
        query
    } else read.socrata(query)
}


#' Get all tables from the API
#' 
#' This function downloads all available tables from the UNdp API
#' 
#' Failed downloads return an error string
#' @export
#' @return list of dataframes
all_undp_tables <- function(){
    lapply(1:18, function(tab){
        tryCatch(fetch_undp_table(table = paste0(tab, ":")),
                 error = function(e){url <- fetch_undp_table(table = paste0(tab, ":"), 
                                                     query_string_only = TRUE)
                             capture.output(getResponse(url, throw_error = FALSE))
                 })
    })
}



