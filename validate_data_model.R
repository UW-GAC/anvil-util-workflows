library(argparser)
library(AnvilDataModels)
library(AnVIL)
library(readr)

argp <- arg_parser("validate")
argp <- add_argument(argp, "--table_files", help="2-column tsv file with (table name, table tsv file)")
argp <- add_argument(argp, "--model_file", help="json file with data model")
argp <- add_argument(argp, "--hash_id_nchar", default=16, help="number of characters in automatically generated ids")
argp <- add_argument(argp, "--use_existing_tables", flag=TRUE, help="for any tables in the data model but not included in table_files, read the existing table from the AnVIL workspace for validation")
argp <- add_argument(argp, "--stop_on_fail", flag=TRUE, help="return an error code if table_files do not pass checks")
argp <- add_argument(argp, "--workspace_name", help="name of AnVIL workspace to import data to")
argp <- add_argument(argp, "--workspace_namespace", help="namespace of AnVIL workspace to import data to")
argv <- parse_args(argp)

# argv <- list(table_files="testdata/table_files.tsv",
#              model_file="testdata/data_model.json")

# read data model
model <- json_to_dm(argv$model_file)

# read tables
table_files <- read_tsv(argv$table_files, col_names=c("names", "files"), col_types="cc")
print("tables to validate:")
print(table_files$names)

# check if we need to add any columns to files
if (length(attr(model, "auto_id")) > 0) {
    tables <- read_data_tables(table_files$files, table_names=table_files$names)
    
    # add auto columns
    tables2 <- lapply(names(tables), function(t) {
        add_auto_columns(tables[[t]], table_name=t, model=model, nchar=argv$hash_id_nchar)
    })
    names(tables2) <- names(tables)
    
    # write new tables
    new_files <- paste("output", names(tables), "table.tsv", sep="_")
    names(new_files) <- names(tables)
    for (t in names(tables2)) {
        write_tsv(tables2[[t]], new_files[t])
    }
} else {
    new_files <- setNames(table_files$files, table_files$names)
}

# write list of tables with names
tibble(name=names(new_files), file=unlist(new_files)) %>%
    write_tsv("output_tables.tsv", col_names=FALSE)

check_files <- new_files
if (argv$use_existing_tables) {
    existing_table_names <- avtables(namespace=argv$workspace_namespace, name=argv$workspace_name)$table
    required_tables <- AnvilDataModels:::.parse_required_tables(names(check_files), model)$required
    workspace_tables <- setdiff(required_tables, names(check_files))
    print("tables read from workspace:")
    print(workspace_tables)
    for (t in workspace_tables) {
        dat <- avtable(t, namespace=argv$workspace_namespace, name=argv$workspace_name)
        if (grepl("_set$", t)) {
            dat <- unnest_set_table(dat)
        }
        check_files[t] <- paste0(t, "_current.tsv")
        write_tsv(dat, check_files[t])
    }
}

params <- list(tables=check_files, model=argv$model_file)
pass <- custom_render_markdown("data_model_report", "data_model_validation", parameters=params)
if (argv$stop_on_fail) {
    if (!pass) stop("table_files not compatible with data model; see data_model_validation.html")
} else {
    writeLines(tolower(as.character(pass)), "pass.txt")
}
