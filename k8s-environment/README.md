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
