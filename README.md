# Purpose

These are the environment bootstrap scripts for the
[BOSH Essentials Course](https://pivotal.io/training/courses/bosh-essentials-training).

Students are typically provided with a pre-provisioned BOSH director to
use during the course.
These scripts are used to help students revisit course material outside
the classroom by generating the scripts necessary to stand up one or
more BOSH director VMs inside Google Cloud Platform.

## Usage

`git clone` this repo onto a Linux system.
[GCP Cloud Shell](https://cloud.google.com/shell/docs/quickstart) is a
simple option but hosting a small dedicated Ubuntu VM on an existing GCP
project with the [GCloud SDK](https://cloud.google.com/sdk/install)
installed and authenticated (as project owner) would represent a more robust
configuration.

There are two options available.

-   Create _each_ director in a dedicated GCP project.
    (preferred)
-   Create _all_ directors in one GCP project.

The primary script to use is `init.sh`.

Before using `init.sh` you _must_ first ensure that each of the student
emails map directly to a genuine GCP account.
Failure to do this will cause the scripts to fail.

## The `init.sh` script

The `init.sh` is used to generate directories that contain templates and
up/down scripts which know how to provision and reclaim BOSH director
VMs.

Inputs:

- a group id variable (optional, randomized when omitted)
- a list of emails

Usage:

```bash
GROUP_ID=123456789 ./init.sh fbloggs@abc.com gbloggs@xyz.com
```

Output:

-   A directory called `envs` that contains the directories for the
    environments requested.
    In this case `bosh-123456789-fbloggs` and `bosh-123456789-gbloggs`.

## The generated `up.sh` script

It is used to deploy a director.

Inputs:

- project id variable (optional)
- billing account id variable (optional)

Usage:

From the `envs` directory, to create a director in its own dedicated
project, run the following.
The billing account id is required for the generation of new projects.

```bash
BILLING_ID=D8876C-B95EA9-0126BB ./envs/[env-to-spin-up]/up.sh
```

Alternatively, if you want to force the director into an existing/shared
project with a linked billing account, run the following.

```bash
PROJECT_ID=blue-star-13579 ./envs/[env-to-spin-up]/up.sh
```

Output:

-   A _*-env_ file.
    This file contains all variables needed to connect to the BOSH
    director that was spun up.

Source an env file to interact with the respective director using the
BOSH CLI.

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

## Multiple environments

Use [tmux](https://en.wikipedia.org/wiki/Tmux) to bring up multiple
environments at once.
It is also helpful to persist logs using the tee command.
in the process so that you can troubleshoot later on if things go wrong.

To force multiple environments to be appear inside a single project, you
must first `export` the `PROJECT_ID` variable.
It is a similar story for the `BILLING_ID` if new projects are to be
created.

Then you can use the following.

```bash
for project in $(ls -d ./envs/*); do
  tmux new-window bash -lic "${project}/up.sh 2>&1 | tee ${project}/up-log.txt"
done
```

To take the environments _down_.

```bash
for project in $(ls -d ./envs/*); do
  tmux new-window bash -lic "${project}/down.sh 2>&1 | tee ${project}/down-log.txt"
done
```

## Testing an environment

To test an environment we need to do the following

- [Install](https://bosh.io/docs/cli-v2-install/) the BOSH cli.
- Source the environment variables of the target environemnt.
- Invoke a BOSH cli method which depends upon the BOSH director.

For eaxmple, the following should produce a meaningful response from the
director.

```bash
source ./envs/[env-to-spin-up]/[env-to-spin-up]-env
bosh env
```
