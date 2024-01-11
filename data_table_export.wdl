version 1.0

workflow data_table_export {
    input {
        Array[String] table_names
        String model_url
        String workspace_name
        String workspace_namespace
    }

    call export_tables {
        input: table_names = table_names,
               model_url = model_url,
               workspace_name = workspace_name,
               workspace_namespace = workspace_namespace
    }

    output {
        Array[File] tables = export_tables.tables
    }

    meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
    }
}

task export_tables {
    input {
        Array[String] table_names
        String model_url
        String workspace_name
        String workspace_namespace
    }

    command <<<
        Rscript -e "\
        model <- AnvilDataModels::json_to_dm('~{model_url}'); \
        tables <- readLines('~{write_lines(table_names)}'); \
        for (t in tables) { \
            dat <- AnVIL::avtable(t, name='~{workspace_name}', namespace='~{workspace_namespace}'); \
            ordered_cols <- intersect(names(model[[t]]), names(dat)); \
            dat <- dat[,ordered_cols]; \
            readr::write_tsv(dat, paste0(t, '.tsv')); \
        } \
        "
    >>>

    output {
        Array[File] tables = glob("*.tsv")
    }

    runtime {
        docker: "uwgac/anvil-util-workflows:0.5.0"
    }
}
