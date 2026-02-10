version 1.0

workflow anvil_test {
    input {
        String project_id
        String workspace_name
        String workspace_namespace
    }

    call test {
        input: project_id = project_id,
               workspace_name = workspace_name,
               workspace_namespace = workspace_namespace
    }

    output {
        File tables = test.tables
    }
}


task test {
    input {
        String project_id
        String workspace_name
        String workspace_namespace
    }

    command <<<
        export GOOGLE_PROJECT=~{project_id}
        R << RSCRIPT
            library(AnVIL)
            tables <- avtables(namespace='~{workspace_namespace}', name~{workspace_name})
            readr::write_tsv(tables, "tables.txt")
        RSCRIPT
    >>>

    output {
        File tables = "tables.txt"
    }
}
