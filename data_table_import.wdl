version 1.0

workflow data_table_import {
    input {
        Map[String, File] table_files
        String model_url
        String workspace_name
        String workspace_namespace
        Boolean overwrite
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
        File file_report = results.file_report
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
        File file_report = "pre_import_check.html"
    }

    runtime {
        docker: "uwgac/anvil-util-workflows:0.2.7"
    }
}
