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

If at a later point your cloud console vm was recreated run `./install_deps.sh`.

To bring the envrionments up run:
```
for project in $(ls -d ~/bosh-course-bootstrap/student-env-*); do
  tmux new-window bash -lic '${project}/up.sh && sleep 10'
done
```

To bring the envrionments down run:
```
for project in $(ls -d ~/bosh-course-bootstrap/student-env-*); do
  tmux new-window bash -lic '${project}/down.sh && sleep 10'
done
```

Students will need the env file located in the envrionment directory:
```
find ~/bosh-course-bootstrap/student-env-*/*-env -exec cloudshell download-file {} \;
```
