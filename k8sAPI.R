alive <<- TRUE

k8s <- import("kubernetes")
source_python('./python/job_crud.py')

k8s$config$load_kube_config()

batch_v1 = k8s$client$BatchV1Api()

#command = list("perl", "-Mbignum=bpi", "-wle", "print bpi(2000)")
job_name <- "pi"
job_image <- "busybox"
command = list("sh", "-c", "echo hello; sleep 10;")

job = create_job_object(job_name,job_image,command)

get_hostname <- function(){
  return(as.character(Sys.info()["nodename"]))
}

#* Create JOB on k8s
#* @serializer text
#* @post /job
function() {
  api_response <- create_job(batch_v1, job)
}

#* Delete JOB on k8s
#* @serializer text
#* @delete /job
function() {
  api_response <- delete_job(batch_v1,job_name)
}

#* Health check. Returns "OK".
#* @serializer unboxedJSON
#* @get /health
function(req, res) {
  future({
    if (!alive) stop() else list(result="OK",hostname=get_hostname(),time = Sys.time())
  })
}

#* Update JOB on k8s
#* @serializer text
#* @put /job
function() {
  api_response <- update_job(batch_v1, job, job_name, job_image)
}

#* get JOB status on k8s
#* @serializer text
#* @get /job
function() {
  api_response <- get_job_status(batch_v1, job_name)
}
