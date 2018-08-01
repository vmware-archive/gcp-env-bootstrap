# bosh-course-bootstrap

The following code _must_ be run from within a Google Cloud Shell session, where tmux is enabled by default.
Your session should be pre-authenticated as an "Owner" of the target project.

From Google Cloud Shell run:
```
git clone https://github.com/platform-acceleration-lab/cf-bosh-course-env-bootstrap-scripts ~/bosh-course-bootstrap
cd ~/bosh-course-bootstrap
```

To create student environments run `./init.sh` which will show:
```
How many student environments do you want to create: 3
Do you wish to create: 3 student environments [yes/no]: yes
Created student-env-1
Created student-env-2
Created student-env-3
Student environments created         
```

Before running the UP / DOWN scripts you should ensure that `bbl` is installed.	
```bash	
if ! [ -x "$(command -v bbl)" ]; then	
    ./install_deps.sh	
fi	
```

The UP / DOWN scripts use tmux windows in GCloud Shell.
Use tmux commands to switch between the windows and monitor progress.

To bring the envrionments "UP" run:
```bash
for project in $(ls -d ~/bosh-course-bootstrap/student-env-*); do
  tmux new-window bash -lic "${project}/up.sh 2>&1 | tee ${project}/up-log.txt"
done
```

To take the envrionments "DOWN" run:
```bash
for project in $(ls -d ~/bosh-course-bootstrap/student-env-*); do
  tmux new-window bash -lic "${project}/down.sh 2>&1 | tee ${project}/down-log.txt"
done
```

Students will need the env file located in the envrionment directory:
```
find ~/bosh-course-bootstrap/student-env-*/*-env -exec cloudshell download-file {} \;
```
