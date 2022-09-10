"""
Creates, updates, and deletes a job object.
"""
from os import path
from time import sleep
import yaml
from kubernetes import client, config

#JOB_NAME = "pi"

def create_job_object(JOB_NAME,JOB_IMAGE):
    # Configureate Pod template container
    container = client.V1Container(
        name=JOB_NAME,
        image=JOB_IMAGE,
        #command=["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
        #command=["sh", "-c", "while true; do echo hello; sleep 10;done"]
        command=["sh", "-c", "echo hello; sleep 10;"]
        #command=JOB_CMD]
        )
    # Create and configure a spec section
    template = client.V1PodTemplateSpec(
        metadata=client.V1ObjectMeta(labels={"app": JOB_NAME}),
        spec=client.V1PodSpec(restart_policy="Never", containers=[container]))
    # Create the specification of deployment
    spec = client.V1JobSpec(
        completions= 1,
        template=template,
        backoff_limit=4)
    # Instantiate the job object
    job = client.V1Job(
        api_version="batch/v1",
        kind="Job",
        metadata=client.V1ObjectMeta(name=JOB_NAME),
        spec=spec)

    return job


def create_job(api_instance, job):
    api_response = api_instance.create_namespaced_job(
        body=job,
        namespace="default")
    print("Job created. status='%s'" % str(api_response.status))
    #get_job_status(api_instance)
    return api_response


def get_job_status(api_instance):
    
    api_response = api_instance.read_namespaced_job_status(
            name=JOB_NAME,
            namespace="default")
    return api_response  

def update_job(api_instance, job):
    # Update container image
    job.spec.template.spec.containers[0].image = "perl"
    api_response = api_instance.patch_namespaced_job(
        name=JOB_NAME,
        namespace="default",
        body=job)
    #print("Job updated. status='%s'" % str(api_response.status))
    return api_response

def delete_job(api_instance):
    api_response = api_instance.delete_namespaced_job(
        name=JOB_NAME,
        namespace="default",
        body=client.V1DeleteOptions(
            propagation_policy='Foreground',
            grace_period_seconds=5))
    #print("Job deleted. status='%s'" % str(api_response.status))
    return api_response
