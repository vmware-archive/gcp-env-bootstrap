# GCP Environment Bootstrap

We teach a number of classes that utilize GCP.
The table below shows which environment needs provisioning or each class.

| Class                                   | Environment                        |
| --------------------------------------- | ---------------------------------- |                         
| PAS Fundamentals                        | [BOSH](bosh-environment/README.md) |
| PKS Fundamentals                        | [BOSH](bosh-environment/README.md) | 
| PAL for Developers on PKS (In progress) | [PKS](pks-environment/README.md)   |

## Setup

1. Clone this repo onto a Linux system.

1. Install the [GCloud SDK](https://cloud.google.com/sdk/install)

1. Log in via the `gcloud` cli with a user that is a Folder Admin for
the CSO-Education folder under the pivotal.io organization in GCP.
