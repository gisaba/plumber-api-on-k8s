alive <<- TRUE

k8s <- import("kubernetes")
source_python('./python/job_crud.py')

k8s$config$load_kube_config()

batch_v1 = k8s$client$BatchV1Api()

#command = ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]

job = create_job_object("pi","busybox")


get_hostname <- function(){
  return(as.character(Sys.info()["nodename"]))
}

#* Create JOB on k8s
#* @serializer text
#* @post /job
function() {
  api_response <- create_job(batch_v1, job)
}

#* Create JOB on k8s
#* @serializer text
#* @delete /job
function() {
  api_response <- delete_job(batch_v1)
}

#* Health check. Returns "OK".
#* @serializer text
#* @get /health
function(req, res) {
  future({
    if (!alive) stop() else paste0("OK-",get_hostname())
  })
}
