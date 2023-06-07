version 1.0

workflow md5_hex {
    input {
        String file
    }

    call results {
        input: file = file
    }

    output {
        String md5 = results.md5
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task results {
    input {
        String file
    }

    command <<<
        gsutil ls -L ~{file} | grep "md5" | awk '{print $3}' > md5_b64.txt
        echo "b64 checksum: "; cat md5_b64.txt
        python3 -c "import base64; import binascii; print(binascii.hexlify(base64.urlsafe_b64decode(open('md5_b64.txt').read())))" | cut -d "'" -f 2 > md5_hex.txt
        echo "hex checksum: "; cat md5_hex.txt
    >>>

    output {
        String md5 = read_string("md5_hex.txt")
    }

    runtime {
        docker: "google/cloud-sdk:slim"
    }
}
