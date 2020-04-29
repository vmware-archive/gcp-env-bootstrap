# Purpose

We use GCP for our courses that require a BOSH environment. This project
helps you do two things:

1. Provision student environments on GCP
1. Deprovision student environments on GCP

## Provisioning

Following these instructions will create student environments on GCP for
each student in a cohort. After provisioning, each student will have:

- A new GCP project
- A BOSH director and jumpbox in that GCP project
- An env file that allows the student to connect to their environment 
    (stored on a GCS bucket)

Provisioning follows these steps:

1. Create a folder on GCP for the cohort
1. Create student environment setup directories with `init.sh`
1. Provision the cohort with `provision-cohort.sh`
1. Email Michael Nemesh and let him know we created projects

### Provision the cohort

1. In the GCP resource manager, within the `pivotal.io` organization,
   within the `CSO-Education` folder, find the folder for the course you
   are creating environments for:

   - PAS Fundamentals: `CSO-Education > pas-fundamentals`
   - PKS Fundamentals: `CSO-Education > pks-fundamentals`

   Within this folder, make a new folder for the class using the cohort
   id as the name. Take note of the folder id that is associated with
   this newly created folder, as it will be needed later.

1. First generate folders in the `envs` directory for each student given. 

    ```bash
    export GROUP_ID=pks-fun-02-22
    ./init.sh <student-1-email> <student-2-email> ...
    ```
    
    The `GROUP_ID` variable should be `pks-fun-mm-dd` or `pas-fun-mm-dd`,
    depending on the course.
    
    This step has no side effects besides creating the folders.

1. Create student environments on GCP

    ```bash
    ./provision-cohort.sh <cohort prefix> <cohort id> <course> <gcp folder id>
    ```

    Arguments:
    - cohort prefix: This should be the same as the `GROUP_ID` above
    - cohort id: Identifier for the cohort from Caddy
    - course: Course you are provisioning. Use the following values:
        - PAS Fundamentals: `pas-fundamentals`
        - PKS Fundamentals: `pks-fundamentals`
    - gcp folder id: **ID** of the GCP folder created earlier - *not the folder name*

    This will deploy a BOSH director and jumpbox using `bbl` as well as
    generate the student env file for each student using these steps:
    
    1. Create a new `tmux` session with the name `provision-<cohort id>`
    1. Create a new window for each student and run `provision.sh`

    TODO: Note about [checking progress using the progress checker](https://www.pivotaltracker.com/story/show/172583482)

1. Email Michael Nemesh

    After the projects have been provisioned, send an email to
    mnemesh@pivotal.io with a list of GCP project that have been created and
    when they can be deleted.

## Deprovisioning

Following these steps will tear down student environments but leave the
project behind. 

TODO: Before `bbl down` need to [destroy all bosh deployments for each director](https://www.pivotaltracker.com/story/show/172570041).

These steps assume you've provisioned student environments using this
repo and the generated folders for each student are still present on the
file system.

### Deprovision the cohort

1. Run the `deprovision-cohort.sh` script to tear down all bbl
    deployments. This does not delete the GCP projects.

    ```bash
    ./deprovision-cohort.sh <cohort prefix> <cohort id> 
    ```

    Arguments:
    - cohort prefix: the same as the GROUP_ID used to provision this cohort
    - cohort id: Identifier for the cohort from Caddy

    This will essentially run `bbl down` for each BOSH deployment using
    these steps:
    
    1. Create a new `tmux` session with the name `deprovision-<cohort id>`
    1. Create a new window for each student in this session and create
        the student's GCP project and run `down.sh`

    TODO: add ability to [check progress of deprovisioning for a cohort](https://www.pivotaltracker.com/story/show/172587433)

## Downloading student env files

To download all student env files for a cohort, use something like this:

```
mkdir "$tmp_folder"
gsutil -m cp "gs://pal-env-files/${course}/${cohort_id}/*" "$tmp_folder" > /dev/null
zip "${tmp_folder}.zip" ${tmp_folder}/* > /dev/null
rm -r "$tmp_folder"
```

## Testing a deployed director

To test an environment we need to do the following:

```bash
source ./envs/[env-to-spin-up]/[env-to-spin-up]-env
bosh env
```
