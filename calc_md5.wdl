version 1.0

workflow calc_md5 {
    input {
        File file
        Int? disk_gb
    }

    call md5 {
        input: file = file,
               disk_gb = disk_gb
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
        File file
        Int disk_gb = 10
    }

    command <<<
        md5sum ~{file} | cut -d " " -f 1 | sed 's/ //g' > md5sum.txt
    >>>

    output {
        String md5sum = read_string("md5sum.txt")
    }

    runtime {
        docker: "ubuntu:18.04"
        disks: "local-disk ${disk_gb} SSD"
    }
}
