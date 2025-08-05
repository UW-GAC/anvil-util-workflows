version 1.0

workflow return_md5 {
    input {
        File file_list
    }

    call md5 {
        input: file_list = file_list
    }
    
    output {
        File md5_table = md5.md5_table
    }
}

task md5 {
    input {
        File file_list
    }

    command <<<
        R << RSCRIPT
            files <- readLines("~{file_list}")
            md5 <- character(length(files))
            for (i in seq_along(files)) {
                chk <- AnVIL::gsutil_stat(files[i])[["Hash (md5)"]]
                if (is.null(chk)) {
                    md5[i] <- NA
                } else {
                    md5[i] <- chk
                }
            }
            md5_tbl <- tibble::tibble(file = files, md5 = md5)
            readr::write_tsv(md5_tbl, "md5_table.tsv")
        RSCRIPT   
    >>>

    output {
        File md5_table = "md5_table.tsv"
    }

    runtime {
        docker: "us.gcr.io/broad-dsp-gcr-public/anvil-rstudio-bioconductor:3.17.0"
    }
}
