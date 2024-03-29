library(argparser)
library(AnvilDataModels)
library(readr)

argp <- arg_parser("import")
argp <- add_argument(argp, "--table_files", help="2-column tsv file with (table name, table tsv file)")
argp <- add_argument(argp, "--model_file", help="json file with data model")
argp <- add_argument(argp, "--overwrite", flag=TRUE, help="overwrite existing rows in tables")
argp <- add_argument(argp, "--workspace_name", help="name of AnVIL workspace to import data to")
argp <- add_argument(argp, "--workspace_namespace", help="namespace of AnVIL workspace to import data to")
argv <- parse_args(argp)

# argv <- list(table_files="testdata/table_files.tsv",
#              model_file="testdata/data_model.json",
#              overwrite=FALSE)

# identify table files
table_files <- read_tsv(argv$table_files, col_names=c("names", "files"), col_types="cc")

# read data model
if (!is.na(argv$model_file)) {
    model <- json_to_dm(argv$model_file)
} else {
    model <- NULL
}

# read tables
tables <- read_data_tables(table_files$files, table_names=table_files$names)

# import tables
anvil_import_tables(tables, model=model, overwrite=argv$overwrite,
                    namespace=argv$workspace_namespace, name=argv$workspace_name)
