library(argparser)
library(magrittr)
library(readr)
library(jsonlite)
library(AnVIL)
sessionInfo()

argp <- arg_parser("backup_data_tables") %>%
    add_argument("--workspace_name", help="Name of workspace to operate on") %>%
    add_argument("--workspace_namespace", help="Namespace of workspace to operate on") %>%
    add_argument("--output_directory", help="Directory to copy files to in workspace bucket")
argv <- parse_args(argp)
print(argv)

bucket <- avbucket(namespace=argv$workspace_namespace, name=argv$workspace_name)

# Loop over tables and write a tsv.
table_json <- list()
tables <- avtables(namespace=argv$workspace_namespace, name=argv$workspace_name)$table
for (t in tables) {
    message(sprintf("Backing up %s", t))
    table_data <- avtable(t, namespace=argv$workspace_namespace, name=argv$workspace_name)
    # outfile <- file.path(tmpdir, sprintf("%s.tsv", table))
    outfile <- sprintf("%s.tsv", t)
    write_tsv(table_data, outfile)
    table_json[[t]] <- file.path(bucket, argv$output_directory, outfile)
}

# Print the files out (for testing?).
list.files()

# Copy the output to the final destination.
gsutil_cp("*.tsv", file.path(bucket, argv$output_directory))

# Save the json file with table inputs.
outfile <- "table_files.json"
writeLines(toJSON(table_json, auto_unbox=TRUE), outfile)
# Copy to the final destination.
gsutil_cp(outfile, file.path(bucket, argv$output_directory))

message("Done!")
