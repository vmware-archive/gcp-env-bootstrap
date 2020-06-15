
# GCP Environment Bootstrapping

## About
This project is designed to assist in the provisioning of GCP projects for PAL training.

At the moment, we provision GCP projects for these classes:

- PAS Fundamentals (for Operators)
- PKS Fundamentals (for Operators)
- PAL for Developers on K8S
- PAL for Platform Engineers on GCP

All classes require a GCP project per student.

The two operator classes also require provisioning a BOSH director per student.

For the developer class instead of a BOSH director, we provision a GKE cluster per student.

## Setup

The scripts in this repository are designed to run on a  linux jumpbox.
They are currently actively run on the machine named 'jumpbox' in the GCP project 'pal-bosh-internal'.

This repository is already cloned onto that machine.
And the script `install_deps.sh` has already been run on that machine.

Therefore, to work with this project on a new machine, you need to:

- make sure you're running on an ubuntu OS
- clone this repository
- run the script `install_deps.sh`

The gcloud SDK comes pre-installed on VMs provisioned in GCP.
Make sure to log in with a user that has _Folder Amin_ permission
on the CSO-Education folder under the pivotal.io organization.

## The init.sh script

This script creates environment subdirectories, one per student.

These directories are created under a subdirectory named `envs`.

All student directories for a cohort are given a common prefix,
using this naming pattern to help identify the associated cohort:

- pasfun-mmdd
- pksfun-mmdd
- k8s-mmdd

e.g. For a PAS Fundamentals class starting on March 3, the prefix is: pasfun-0303

### Running the script

Inputs:

- the cohort prefix, as an environment variable
- the cohort's roster, represented by a list of email addresses, provided as command line arguments

Example:

```bash
export COHORT_PREFIX=pksfun-0222
./init.sh <student-1-email> <student-2-email> ...
```

After the script runs, inspect the `envs/` subdirectory.

Each student subdirectory contains symlinks to scripts located in `template/`.

## Provisioning GCP projects for a cohort

1. In the GCP resource manager, within the `pivotal.io` organization,
   within the `CSO-Education` folder, find the folder for the course you
   are creating environments for:

   - PAS Fundamentals: `CSO-Education > pas-fundamentals`
   - PKS Fundamentals: `CSO-Education > pks-fundamentals`

   Within this folder, make a new folder for the class using the cohort
   id as the name. Take note of the folder id that is associated with
   this newly created folder.

1. Create three environment variables:

    ```bash
    export COHORT_PREFIX="..." # the cohort prefix you used with init.sh earlier
    export COHORT_ID="..."
    export GCP_FOLDER_ID="..."  # the gcp folder id from the previous step
    ```

1. Run the script `provision-gcp-projects` as follows:

    ```bash
    ./provision-gcp-projects.sh $COHORT_PREFIX $COHORT_ID $GCP_FOLDER_ID
    ```

    The projects are created in parallel using separate tmux windows in a single tmux session.
    You can monitor the progress for an environment by tailing the _provision log file_ located
    in each environment directory:

    ```bash
    tail -f provision-log.txt
    ```

    Besides creating the projects, each project is configured with the pivotal.io
    billing id, specific GCP apis are enabled, and service accounts are created
    and associated with the project.

1. Verify the gcp projects have been created.
   If you encountered an error, it is safe to re-run the script.

   To tell whether this step is done, you can inspect whether a tmux session
   is still running:

   ```bash
   tmux list-sessions  # tmux ls is a nice shorthand
   ```

   You can also list tmux windows:

   ```bash
   tmux list-windows
   ```

The creation of these projects must be communicated to Michael Nemesh.
If all projects are for a single cohort, all you need to relate is the folder name and id
(in the CSO-Education hierarchy) that contains all the gcp projects.

## Provisioning BOSH directors for a cohort

Bosh directors are provisioned with the aid of the bosh bootloader (bbl).

```bash
./provision-bosh-directors.sh $COHORT_PREFIX $COHORT_ID pas-fundamentals|pks-fundamentals
```

Above, the third argument is either `pas-fundamentals` or `pks-fundamentals`.

Again, you can tail the bosh provisioning log file to monitor progress:

```bash
tail -f provision-bosh-log.txt
```

The provisioning of bosh directors can take some time.
Be patient.
Thanks to tmux, you are free to log out of the jumpbox altogether and come back later.

You can verify whether the process is still running by checking to see if the tmux session is still alive:

```bash
tmux ls
```

The output is a set of environment files, one per student, used to configure their bosh cli.

The environment files are deposited to gcs, in the gcp project `pal-bosh-internal`,
in the bucket `pal-env-files`, in a subdirectory named after the class's cohort id.

### Downloading student env files

To download all student env files for a cohort, use something like this:

```bash
gsutil -m cp -R "gs://pal-env-files/${course}/${cohort_id}" .
```

We recommend that you download and test each environment before handing them off to the
instructor:

```bash
source <env-file-name>
bosh env
```

It's a nice touch to email the environment files to the principal instructor
of the upcoming delivery.

## Provisioning GKE clusters for a cohort

Run the script:

```bash
./provision-gke-clusters.sh $COHORT_PREFIX $COHORT_ID
```

You can tail the gke clusters provisioning log file to monitor progress:

```bash
tail -f provision-gke-log.txt
```

### Create NS Entry in Route 53

The following script will create NS entries in aws route 53
for each student:

```bash
./make-all-aws-ns-records.sh $COHORT_PREFIX
```

** The aws cli must be installed and configured (~/.aws/credentials with access key id and secret)
