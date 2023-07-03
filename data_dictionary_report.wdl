version 1.0

workflow data_dictionary_report {
    input {
        File data_file
        String dd_url
    }

    call validate {
        input: data_file = data_file,
               dd_url = dd_url
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
        File data_file
        String dd_url
    }

    command {
        Rscript /usr/local/anvil-util-workflows/data_dictionary_report.R \
            --data_file ${data_file} \
            --dd_file ${dd_url}
    }

    output {
        File validation_report = "data_dictionary_validation.txt"
        Boolean pass_checks = read_boolean("pass.txt")
    }

    runtime {
        docker: "uwgac/anvil-util-workflows:0.3.1"
    }
}
