version 1.0

workflow backup_data_tables {
  input {
    String workspace_namespace
    String workspace_name
    String output_directory
    Boolean overwrite = false
  }
  call backup_tables {
    input: workspace_namespace=workspace_namespace,
      workspace_name=workspace_name,
      output_directory=output_directory,
      overwrite=overwrite
  }

  meta {
    author: "Adrienne Stilp"
    email: "amstilp@uw.edu"
  }

}


task backup_tables {
  input {
    String workspace_namespace
    String workspace_name
    String output_directory
    Boolean overwrite
  }
  command {
    set -e
    Rscript /usr/local/anvil-util-workflows/backup_data_tables.R \
        --workspace_namespace ~{workspace_namespace} \
        --workspace_name ~{workspace_name} \
        ${true="--overwrite" false="" overwrite} \
        --output_directory ~{output_directory}
  }
  runtime {
    # Pull from DockerHub
    docker: "uwgac/anvil-util-workflows:0.4.3.1"
  }
}
