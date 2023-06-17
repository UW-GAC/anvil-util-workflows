version 1.0

workflow validate_data_model {
    input {
        Map[String, File] table_files
        String model_url
        String workspace_name
        String workspace_namespace
        Boolean overwrite = false
        Boolean import_tables = false
        Int? hash_id_nchar
    }

    call results {
        input: table_files = table_files,
               model_url = model_url,
               hash_id_nchar = hash_id_nchar,
               workspace_name = workspace_name,
               workspace_namespace = workspace_namespace,
               overwrite = overwrite,
               import_tables = import_tables
    }

    output {
        File validation_report = results.validation_report
        Map[String, File]? tables = results.tables
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
        String workspace_name
        String workspace_namespace
        Boolean overwrite
        Boolean import_tables
        Int hash_id_nchar = 16
    }

    command {
        Rscript /usr/local/anvil-util-workflows/validate_data_model.R \
            --table_files ${write_map(table_files)} \
            --model_file ${model_url} \
            --workspace_name ${workspace_name} \
            --workspace_namespace ${workspace_namespace} \
            --stop_on_fail --use_existing_tables \
            --hash_id_nchar ${hash_id_nchar}
        if [[ "~{import_tables}" == "true" ]]
        then
          Rscript /usr/local/anvil-util-workflows/data_table_import.R \
            --table_files output_tables.tsv \
            --model_file ${model_url} ${true="--overwrite" false="" overwrite} \
            --workspace_name ${workspace_name} \
            --workspace_namespace ${workspace_namespace}
        fi
    }

    output {
        File validation_report = "data_model_validation.html"
        Map[String, File]? tables = read_map("output_tables.tsv")
    }

    runtime {
        docker: "uwgac/anvil-util-workflows:0.3.1.2"
    }
}
