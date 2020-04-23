# Purpose

These are the environment bootstrap scripts for spinning student environments
for PAL for Developers on Kubernetes. 

Following these instructions will create GCP projects with 
a GKE cluster installed.

## Set up

1. Set GROUP_ID for the cohort your are provisioning
    ```bash
    export GROUP_ID=k8s-<cohort-id>
    ```
1. Run ./init.sh with each student in the cohort
    ```bash
    ./init.sh student1@example.com student2@example.com
    ```

1. For each student, run the provision.sh script
    ```bash
    ./envs/path-to-student-dir/provision.sh <cohort-id> <folder-id>
    ```
   Arguments:
    - Cohort ID: ID of the cohort
    - Folder ID: ID of the folder on GCP

1. For each student, set up DNS

    1. Get IP address for ingress router
        ```
        kubectl get service ingress-nginx --namespace=ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
        ```
    1. Create DNS Zone in GCP
        1. Zone name: pal-for-devs-k8s
        1. DNS name: <student>.k8s.pal.pivotal.io
    1. Copy value of NS Record and go to Route 53
    1. Go into Hosted Zone for k8s course (k8s.pal.pivotal.io)
    1. Create Record Set for the student
        1. Name: <student-name> (from the generated student env file)
        1. Type: NS Record
        1. TTL: 60
        1. Value: NS records from GCP
    1. Go back to GCP DNS zone
    1. Add a record set to GCP DNS Zone
        1. DNS Name: *
        1. Type: A record
        1. Value: IP address of ingress router
