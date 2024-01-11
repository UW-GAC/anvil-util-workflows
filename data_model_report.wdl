version 1.0

workflow data_model_report {
    input {
        Map[String, File] table_files
        String model_url
    }

    call validate {
        input: table_files = table_files,
               model_url = model_url
    }

    output {
        File validation_report = validate.validation_report
        Boolean pass_checks = validate.pass_checks
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
    }
}

task validate {
    input {
        Map[String, File] table_files
        String model_url
    }

    command <<<
        Rscript /usr/local/anvil-util-workflows/validate_data_model.R \
            --table_files ~{write_map(table_files)} \
            --model_file ~{model_url} \
            --skip_hash_id
    >>>

    output {
        File validation_report = "data_model_validation.html"
        Boolean pass_checks = read_boolean("pass.txt")
    }

    runtime {
        docker: "uwgac/anvil-util-workflows:0.5.0"
    }
}
