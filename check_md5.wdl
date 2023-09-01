version 1.0

workflow check_md5 {
    input {
        String file
        String md5sum
        String? project_id
    }

    call md5check {
        input: file = file,
               md5sum = md5sum,
               project_id = project_id
    }

    output {
        String md5_check = md5check.md5_check
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task md5check {
    input {
        String file
        String md5sum
        String? project_id
    }

    String project_id_string = if defined(project_id) then "-u " + project_id else ""

    command <<<
        set -e
        gsutil ~{project_id_string} ls -L ~{file} 2> errors.txt | grep "md5" | awk '{print $3}' > md5_b64.txt
        if [[ $(<errors.txt) =~ 'CommandException' ]]; then
            cat errors.txt
            exit 1
        fi
        echo "b64 checksum: "; cat md5_b64.txt
        python3 -c "import base64; import binascii; print(binascii.hexlify(base64.urlsafe_b64decode(open('md5_b64.txt').read())))" | cut -d "'" -f 2 > md5_hex.txt
        echo "hex checksum: "; cat md5_hex.txt
        echo "hex provided: ~{md5sum}"
        python3 -c "print('PASS') if open('md5_hex.txt').read().strip() == '~{md5sum}' else print('UNVERIFIED') if open('md5_hex.txt').read().strip() == '' else print('FAIL')" > check.txt
        if [[ $(<check.txt) = 'FAIL' ]]; then
            exit 1
        fi
    >>>

    output {
        String md5_check = read_string("check.txt")
    }

    runtime {
        docker: "google/cloud-sdk:slim"
    }
}


task summarize_md5_check {
    input {
        Array[String] file
        Array[String] md5_check
    }

    command <<<
        Rscript -e "\
        files <- readLines('~{write_lines(file)}'); \
        checks <- readLines('~{write_lines(md5_check)}'); \
        library(dplyr); \
        dat <- tibble(file_path=files, md5_check=checks); \
        readr::write_tsv(dat, 'details.txt'); \
        ct <- mutate(count(dat, md5_check), x=paste(n, md5_check)); \
        writeLines(paste(ct[['x']], collapse=', '), 'summary.txt'); \
        "
    >>>
    
    output {
        String summary = read_string("summary.txt")
        File details = "details.txt"
    }

    runtime {
        docker: "us.gcr.io/broad-dsp-gcr-public/anvil-rstudio-bioconductor:3.17.0"
    }
}
