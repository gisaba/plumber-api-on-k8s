library(reticulate)
rm(ls())
use_python("C:/Users/utente/AppData/Local/Programs/Python/Python310")

setwd("C:/Users/utente/Documents/R-Project/plumber/plumber-api-on-k8s")
getwd()
setwd("./python")
getwd()

os <- import("os")
#os$listdir(".")

#k8s <- import("kubernetes")

#py_install("kubernetes")



#source_python('add.py')
#add(5, 10)
#py_run_file("add.py")
#py_run_string("x = 10")
#py$x

#source_python('k8s.py')
#is.data.frame(ret)
#class(ret)
#for (pod in ret$items) {
#  print(pod$metadata$name)
#}

source_python('job_crud.py')

JOB_NAME = "pi"

k8s$config$load_kube_config()
batch_v1 = k8s$client$BatchV1Api()

# Create a job object with client-python API. The job we
# created is same as the `pi-job.yaml` in the /examples folder.
job = create_job_object()

api_response <- create_job(batch_v1, job)

status <- get_job_status(batch_v1)
status

api_response <- update_job(batch_v1, job)

api_response <- delete_job(batch_v1)
