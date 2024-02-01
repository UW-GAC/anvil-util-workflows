version 1.0

workflow md5_hex {
    input {
        String file
        String? project_id
    }

    call md5 {
        input: file = file,
               project_id = project_id
    }

    output {
        String md5sum = md5.md5sum
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task md5 {
    input {
        String file
        String? project_id
    }

    String project_id_string = if defined(project_id) then "-u " + project_id else ""

    command <<<
        gsutil ~{project_id_string} ls -L ~{file} | grep "md5" | awk '{print $3}' > md5_b64.txt
        echo "b64 checksum: "; cat md5_b64.txt
        python3 -c "import base64; import binascii; print(binascii.hexlify(base64.urlsafe_b64decode(open('md5_b64.txt').read())))" | cut -d "'" -f 2 > md5_hex.txt
        echo "hex checksum: "; cat md5_hex.txt
    >>>

    output {
        String md5sum = read_string("md5_hex.txt")
    }

    runtime {
        docker: "google/cloud-sdk:slim"
    }
}
