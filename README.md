# BOSH environment bootstrap scripts

## Overview

Clone this repo onto a linux system.

The scripts contained in this repo are designed to deploy BOSH directors to GCP and to allow users to easily interact
with the generated directors.

There are two general options.
-   One director per GCP project.
-   All directors in one GCP project.

There are three main scripts to use, `init.sh`, `up.sh` and `down.sh`.


## The `init.sh` script

It is used to generate directories that contain templates and scripts to deploy a director.

Inputs:
- group id variable (optional, randomized when omitted)
- list of emails

Usage:
```
GROUP_ID=123456789 ./init.sh fbloggs@abc.com gbloggs@xyz.com
```

Output:

-   A directory called `envs` that contains the directories for the environments requested. 
    In this case: `bosh-123456789-fbloggs` and `bosh-123456789-gbloggs`.


## The `up.sh` script

It is used to deploy a director. 

Inputs:
- project id variable (optional)

Usage:

From the `envs` directory run the following.
```bash
./envs/[env-to-spin-up]/up.sh
```

This will create a separate GCP project. In order to achieve this they need to be run by a user with sufficient rights
to create projects in a GCP organization.


To use (or create) a GCP project of your own choice run the following.
```
PROJECT_ID=blue-star-13579 ./envs/[env-to-spin-up]/up.sh
```

Output:

- A _*-env_ file. This file contains all variables needed to connect to the BOSH director that was spun up.



Source an env file to interact with the respective director using the BOSH CLI.

## The `down.sh` script

This will remove the director and jumpbox, clean up the VMs, disks and networks and remove all users the up script had
created.


Usage:

From the `envs` directory run the following.
```bash
./[env-to-take-down]/down.sh
```

Output:

- A clean GCP project with all traces of the director removed.


## Multiple environments

Use [tmux](https://en.wikipedia.org/wiki/Tmux) to bring up multiple environments at once.
It is also helpful to store logs using [tee](https://en.wikipedia.org/wiki/Tee_(command)) in the process so that you can
trouble shoot later on if things go wrong.

To bring multiple environments _up_.

```
for project in $(ls -d ./envs/*); do
  tmux new-window bash -lic "${project}/up.sh 2>&1 | tee ${project}/up-log.txt"
done
```

To take the environments _down_.

```
for project in $(ls -d ./envs/*); do
  tmux new-window bash -lic "${project}/down.sh 2>&1 | tee ${project}/down-log.txt"
done
```

