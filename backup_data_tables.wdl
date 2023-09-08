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
  runtime {
    # Pull from DockerHub
    docker: "uwgac/anvil-util-workflows:0.4.2.1"
  }
}
