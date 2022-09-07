k8s <- import("kubernetes")
source_python('./python/job_crud.py')

k8s$config$load_kube_config()
batch_v1 = k8s$client$BatchV1Api()
job = create_job_object()

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
