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
        cut -d ":" -f 2 tmp | sed 's/ //g' > check.txt
    }

    output {
        String md5_check = read_string("check.txt")
    }

    runtime {
        docker: "ubuntu:18.04"
    }
}
