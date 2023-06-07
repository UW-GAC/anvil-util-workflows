version 1.0

workflow data_table_import {
    input {
        Map[String, File] table_files
        String model_url
        String workspace_name
        String workspace_namespace
        Boolean overwrite = false
        Boolean validate = true
    }

    call results {
        input: table_files = table_files,
               model_url = model_url,
               workspace_name = workspace_name,
               workspace_namespace = workspace_namespace,
               overwrite = overwrite,
               validate = validate
    }

    output {
        File? validation_report = results.validation_report
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
        Boolean validate
    }
    
    command {
        Rscript /usr/local/anvil-util-workflows/data_table_import.R \
            --table_files ${write_map(table_files)} ${true="--overwrite" false="" overwrite} \
            --model_file ${model_url} ${true="--validate" false="" validate} \
            --workspace_name ${workspace_name} \
            --workspace_namespace ${workspace_namespace}
    }

    output {
        File? validation_report = "data_model_validation.html"
    }

    runtime {
        docker: "uwgac/anvil-util-workflows:0.3.0"
    }
}
