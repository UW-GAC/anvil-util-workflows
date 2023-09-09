library(argparser)
library(magrittr)
library(readr)
library(stringr)
library(jsonlite)
library(AnVIL)
sessionInfo()

argp <- arg_parser("backup_data_tables") %>%
    add_argument("--workspace_name", help="Name of workspace to operate on") %>%
    add_argument("--workspace_namespace", help="Namespace of workspace to operate on") %>%
    add_argument("--overwrite", flag=TRUE, help="ovewrite existing files if they exist") %>%
    add_argument("--output_directory", help="Directory to copy files to in workspace bucket")
argv <- parse_args(argp)
print(argv)

bucket <- avbucket(namespace=argv$workspace_namespace, name=argv$workspace_name)

outdir <- file.path(bucket, argv$output_directory)

# Check if the output directory already exists.
bucket_files <- gsutil_ls(bucket)
print(bucket_files)
outdir_exists <- any(str_detect(bucket_files, outdir))
print(outdir_exists)
if (outdir_exists & !argv$overwrite) {
    stop(sprintf("Output directory already exists: %s", outdir))
}

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
print(outdir)
gsutil_cp("*.tsv", outdir)

# Save the json file with table inputs.
outfile <- "table_files.json"
writeLines(toJSON(table_json, auto_unbox=TRUE), outfile)
# Copy to the final destination.
gsutil_cp(outfile, outdir)

message("Done!")
