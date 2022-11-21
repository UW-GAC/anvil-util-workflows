library(argparser)
library(AnvilDataModels)

argp <- arg_parser("report")
argp <- add_argument(argp, "--data_file", help="tsv file with data")
argp <- add_argument(argp, "--dd_file", help="json file with data dictionary for GSR files")
argp <- add_argument(argp, "--out_prefix", help="output prefix")

# argv <- list(data_file="testdata/gsr_chr1.tsv",
#              dd_file="testdata/gsr_dd.json",
#              out_prefix="test")

# read data model
dd <- json_to_dm(argv$dd_file)

# read 1000 rows for checking data against expected type
dat <- readr::read_tsv(argv$data_file, n_max=1000)
dat <- list(dat)
names(dat) <- names(dd)

outfile <- paste0(argv$out_prefix, ".txt")
con <- file(outfile, "w")

pass <- TRUE
chk <- check_column_names(dat, dd)
res <- parse_column_name_check(chk)
if (nrow(res) > 0) {
    if (length(chk[[1]]$missing_required_columns) > 0) pass <- FALSE
    writeLines(knitr::kable(res[,-1]), con)
    writeLines("\n", con)
}

chk <- check_column_types(dat, dd)
res <- parse_column_type_check(chk)
if (nrow(res) > 0) {
    pass <- FALSE
    writeLines(knitr::kable(res[,-1]), con)
}

close(con)

writeLines(tolower(as.character(pass)), "pass.txt")
