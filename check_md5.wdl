version 1.0

workflow check_md5 {
    input {
        File file
        String md5sum
    }

    call results {
        input: file = file,
               md5sum = md5sum   
    }

    output {
        String check = results.check
    }

     meta {
          author: "Stephanie Gogarten"
          email: "sdmorris@uw.edu"
     }
}

task results {
    input {
        File file
        String md5sum
    }

    command {
        echo "${md5sum}  ${file}" | md5sum -c > tmp
        awk -F': ' '{print $2}' tmp > check.txt
    }

    output {
        String check = read_string("check.txt")
    }

    runtime {
        docker: "ubuntu:18.04"
    }
}
