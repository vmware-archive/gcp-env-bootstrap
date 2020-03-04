# GCP Environment Bootstrap

We teach a number of classes that utilize GCP:

- PAS Fundamentals
- PKS Fundamentals
- PAL for Developers on PKS (In progress)

To provision student environments for a PAS Fundamentals or PKS Fundamental
cohort, follow the instructions [here](bosh/README.md).

To provision student environments for a PAL for Developers on PKS
cohort, follow the instructions [here](pks/README.md).

## Setup

1. Clone this repo onto a Linux system.

1. Install the [GCloud SDK](https://cloud.google.com/sdk/install)

1. Log in via the `gcloud` cli with a user that is a Folder Admin for
the CSO-Education folder under the pivotal.io organization in GCP.
