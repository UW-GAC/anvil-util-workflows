version 1.0

workflow data_model_report {
    input {
        Map[String, File] table_files
        String model_url
    }

    call results {
        input: table_files = table_files,
               model_url = model_url
    }

    output {
        File validation_report = results.validation_report
        Map[String, File]? tables = results.tables
        Boolean pass_checks = results.pass_checks
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
    }
}

task results {
    input {
        Map[String, File] table_files
        String model_url
    }

    command {
        Rscript /usr/local/anvil-util-workflows/validate_data_model.R \
            --table_files ${write_map(table_files)} \
            --model_file ${model_url}
    }

    output {
        File validation_report = "data_model_validation.html"
        Map[String, File]? tables = read_map("output_tables.tsv")
        Boolean pass_checks = read_boolean("pass.txt")
    }

    runtime {
        docker: "uwgac/anvil-util-workflows:0.3.1.2"
    }
}
