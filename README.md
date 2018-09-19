# bosh-course-bootstrap

Your session needs to be pre-authenticated as a user capable of creating GCP projects.

Clone this repo.

The `./init.sh` requires a variable named `COHORT_ID` to be set and a list of student emails provided as script
arguments.

For example:
```
COHORT_ID=123456789 ./init.sh fbloggs@abc.com gbloggs@xyz.com
```

Which will produce the following output.
```
The following environments will be created:
- bosh-123456789-fbloggs (fbloggs@abc.com)
- bosh-123456789-gbloggs (gbloggs@xyz.com)
Are you sure?
```

Follow the prompt to create the `envs` directory, which will hold a directory with each of the environments you
requested.



To bring an  environment up cd into the directory of the environment you want to spin up  and run:
```bash
./up.sh
```

To take an environment down cd into the directory of the environment you want to take down and run:
```bash
./down.sh
```

Students will need the env file located in each environment directory, in our example they would be the following.
```
envs/bosh-123456789-gbloggs/bosh-123456789-gbloggs-env
envs/bosh-123456789-fbloggs/bosh-123456789-fbloggs-env
```

In order to force all environments to be created/destroyed inside a single project you can export/inject the
`PROJECT_ID` variable into the up/down scripts.
