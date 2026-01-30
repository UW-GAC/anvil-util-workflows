version 1.0

workflow copy_create_md5 {
    input {
        String old_bucket_path
        String new_bucket_path
        String? project_id
    }

    call daisy_chain_copy {
        input:
            old_bucket_path = old_bucket_path,
            new_bucket_path = new_bucket_path,
            project_id = project_id
    }
}


task daisy_chain_copy {
    input {
        String old_bucket_path
        String new_bucket_path
        String? project_id
    }

    command <<<
        gsutil ~{"-u " + project_id} cp -D ~{old_bucket_path} ~{new_bucket_path}
    >>>

    runtime {
        docker: "google/cloud-sdk:slim"
    }
}
