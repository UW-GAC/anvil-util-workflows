version 1.0

workflow backup_data_tables {
  input {
    String workspace_namespace
    String workspace_name
    String output_directory
  }
  call backup_tables {
    input: workspace_namespace=workspace_namespace,
      workspace_name=workspace_name,
      output_directory=output_directory
  }
  output {
    # Should there actually be output from this workflow if the files are copied to the bucket?
    Array[File] tables = backup_tables.table_files
    File json_file = backup_tables.json_file
  }
}


task backup_tables {
  input {
    String workspace_namespace
    String workspace_name
    String output_directory
  }
  command {
    set -e
    Rscript /usr/local/anvil-util-workflows/backup_data_tables.R \
        --workspace_namespace ~{workspace_namespace} \
        --workspace_name ~{workspace_name} \
        --output_directory ~{output_directory}
  }
  output {
    # Should there actually be output from this workflow if the files are copied to the bucket?
    Array[File] table_files = glob("*.tsv")
    File json_file = "table_files.json"
  }
  runtime {
    # Pull from DockerHub
    docker: "uwgac/anvil-util-workflows:0.4.1.1"
  }
}
