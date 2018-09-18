# bosh-course-bootstrap

The following code _must_ be run from within a tmux session.
Your session should be pre-authenticated as a user capable of creating GCP projects.

Clone this repo:
```
git clone https://github.com/platform-acceleration-lab/cf-bosh-course-env-bootstrap-scripts ~/bosh-course-bootstrap
cd ~/bosh-course-bootstrap
```

The `./init.sh` requires a variable named `COHORT_ID` to be set and a list of student emails are script arguments.
For example:
```
COHORT_ID=123456789 ./init.sh fbloggs@abc.com gbloggs@xyz.com
```

Which should produce the following output.
```
The following environments will be created:
- bosh-123456789-fbloggs (fbloggs@abc.com)
- bosh-123456789-gbloggs (gbloggs@xyz.com)
Are you sure?
```

Follow the prompt to create the `envs` directories.

The UP / DOWN scripts use tmux windows.
Use tmux commands to switch between the windows and monitor progress.

To bring the envrionments "UP" run:
```bash
for project in $(ls -d ~/bosh-course-bootstrap/envs/*); do
  tmux new-window bash -lic "${project}/up.sh 2>&1 | tee ${project}/up-log.txt"
done
```

To take the envrionments "DOWN" run:
```bash
for project in $(ls -d ~/bosh-course-bootstrap/envs/*); do
  tmux new-window bash -lic "${project}/down.sh 2>&1 | tee ${project}/down-log.txt"
done
```

Students will need the env file located in the envrionment directory:
```
find ~/bosh-course-bootstrap/envs/*/*-env -exec cloudshell download-file {} \;
```

In order to force all environments to be created/destroyed inside a single project you should export/inject the `PROJECT_ID` variable into the up/down scripts.
