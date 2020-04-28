# Purpose

These are the environment bootstrap scripts for spinning student environments
for PAS Fundamentals and PKS Fundamentals. 

Following these instructions will create GCP projects with a jumpbox and BOSH
director installed.

## Usage

Provisioning environments follows three steps:

1. GCP environment set up
1. Initializing setup scripts
1. Creating student environments

The primary script to use is `init.sh`.

## GCP environment set up

### Create a folder for the class

In the GCP resource manager, within the `pivotal.io` organization,
within the `CSO-Education` folder, find the folder for the course you
are creating environments for:

- PAS Fundamentals: `CSO-Education > pas-fundamentals`
- PKS Fundamentals: `CSO-Education > pks-fundamentals`

Within this folder, make a new folder for the class using the cohort id
as the name.
Take note of the folder id that is associated with this newly created
folder, as it will be needed later.

## Initializing setup scripts

The `init.sh` is used to generate directories that contain templates and
up/down scripts which know how to provision and reclaim BOSH director
VMs.

Inputs:

Command line:
- A `GROUP_ID` variable (optional, randomized when omitted) 
  This is an identifier for the set of GCP projects being created.
  Use the naming convention `pksfun-mmdd` or `pasfun-mmdd` for the PKS
  Fundamentals and PAS Fundamentals courses respectively.
- A list of email addresses

Usage:

```bash
export GROUP_ID=pksfun-0503
./init.sh fbloggs@abc.com gbloggs@xyz.com
```

Output:

-   A directory called `envs` that contains the directories for the
    environments requested.
    In this case `pksfun-0503-fbloggs` and `pksfun-0503-gbloggs`.

## Creating student environments

Each environment has an `provision.sh` script. It is used to create the
GCP project and deploy both a jumpbox and a Bosh director to it.

You'll execute the generated `provision.sh` for each directory that was
created. 

```bash
./envs/[env-to-spin-up]/provision.sh <gcp folder id> <gcs folder path>
```

Inputs:

- gcp folder id: ID of the folder on GCP
- gcs folder path: location to store student credentials, stored on GCS

  PKS Fundamentals: "pks-fundamentals/<cohort-id>"
  PAS Fundamentals: "pas-fundamentals/<cohort-id>"

Usage:

After the `provision.sh` script finishes, check the output for any
uncaught errors.

Output:

-   A _*-env_ file.
    This file contains all variables needed to connect to the BOSH
    director that was spun up.

Source an env file to interact with the respective director using the
BOSH CLI.

## Downloading student env files

To download all student env files for a cohort, use the `gsutil` command.

```
gsutil cp -r gs://pal-env-files/pks-fun-0330/* ~/Desktop/envs
```

## Testing a deployed director

To test an environment we need to do the following

- [Install](https://bosh.io/docs/cli-v2-install/) the BOSH cli.
- Source the environment variables of the target environment.
- Invoke a BOSH cli method which depends upon the BOSH director.

For example, the following will produce a meaningful response from the
director.

```bash
source ./envs/[env-to-spin-up]/[env-to-spin-up]-env
bosh env
```

## The generated `down.sh` script

This will remove the director and jumpbox, clean up the VMs, disks and
networks and remove all users the up script had created.

Usage:

From the `envs` directory run the following.

```bash
./[env-to-take-down]/down.sh
```

Output:

- A clean GCP project with all traces of the director removed.

## Deprovisioning

We can't delete GCP projects, so deleting VMs after a cohort ends is the
next best thing. To run `bbl down` on all projects in a cohort, use
`deprovision-cohort.sh`:

    ```
    ./deprovision-cohort.sh <group id> <cohrt id>
    ```

This will create a tmux session with windows running `bbl down` for each
project in the `envs/` directory that matches that `group id` param.

## Multiple environments

Use [tmux](https://en.wikipedia.org/wiki/Tmux) to bring up multiple
environments at once.
It is also helpful to persist logs using the tee command.
in the process so that you can troubleshoot later on if things go wrong.

To force multiple environments to appear inside a single project, you
must first `export` the `PROJECT_ID` variable.
It is a similar story for the `BILLING_ID` if new projects are to be
created.

Then you can use the following.

```bash
for project in $(ls -d ./envs/${GROUP_ID}*); do
  tmux new-window bash -lic "${project}/up.sh 2>&1 | tee ${project}/up-log.txt";
done
```

## Email Michael Nemish with environment info

After the projects have been provisioned, send an email to
mnemish@pivotal.io with a list of GCP project that have been created and
when they can be deleted.
