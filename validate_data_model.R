library(argparser)
library(AnvilDataModels)

argp <- arg_parser("report")
argp <- add_argument(argp, "--table_files", help="2-column tsv file with (table name, table tsv file)")
argp <- add_argument(argp, "--model_file", help="json file with data model")
argp <- add_argument(argp, "--import_tables", flag=TRUE, help="import tables after validation")
argp <- add_argument(argp, "--overwrite", flag=TRUE, help="overwrite existing rows in tables")
argp <- add_argument(argp, "--workspace_name", help="name of AnVIL workspace to import data to")
argp <- add_argument(argp, "--workspace_namespace", help="namespace of AnVIL workspace to import data to")
argv <- parse_args(argp)

# argv <- list(table_files="testdata/table_files.tsv",
#              model_file="testdata/data_model.json")

# read data model
model <- json_to_dm(argv$model_file)

# read tables
table_files <- readr::read_tsv(argv$table_files, col_names=c("names", "files"), col_types = readr::cols())

# check if we need to add any columns to files
if (length(attr(model, "auto_id")) > 0) {
    tables <- read_data_tables(table_files$files, table_names=table_files$names)
    
    # add auto columns
    tables2 <- lapply(names(tables), function(t) {
        add_auto_columns(tables[[t]], table_name=t, model=model)
    })
    names(tables2) <- names(tables)
    
    # write new tables
    new_files <- paste("output", names(tables), "table.tsv", sep="_")
    names(new_files) <- names(tables)
    for (t in names(tables2)) {
        readr::write_tsv(tables2[[t]], new_files[t])
    }
} else {
    new_files <- setNames(table_files$files, table_files$names)
}

params <- list(tables=new_files, model=argv$model_file)
pass <- custom_render_markdown("data_model_report", "data_model_validation", parameters=params)
writeLines(tolower(as.character(pass)), "pass.txt")

if (pass & argv$import_tables) {
    tables <- read_data_tables(new_files)
    anvil_import_tables(tables, model=model, overwrite=argv$overwrite,
                        namespace=argv$workspace_namespace, name=argv$workspace_name)
}
