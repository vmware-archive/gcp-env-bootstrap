# bosh-course-bootstrap

From google web cloud console run:
```
git clone https://github.com/rkoster/bosh-course-bootstrap
cd bosh-course-bootstrap
```

To create student environments run `./init.sh` which will show:
```
rkoster@cloudshell:~/bosh-course-bootstrap (cso-education-pcfpredayone)$ ./init.sh
How many student environments do you want to create: 3
Do you wish to create: 3 student environments [yes/no]: yes
OK
deb http://apt.starkandwayne.com stable main
Get:1 http://security.debian.org/debian-security stretch/updates InRelease [94.3 kB]
Ign:2 http://deb.debian.org/debian stretch InRelease                                                                                        
Get:3 http://deb.debian.org/debian stretch-updates InRelease [91.0 kB]                                                                      
Hit:4 http://deb.debian.org/debian stretch Release                                                         
Hit:5 http://storage.googleapis.com/bazel-apt stable InRelease 
...          
```

If at a later point your cloud console vm was recreated run `./install_deps.sh`.

To bring the envrionments up run:
```
for project in $(ls student-env-*); do
  tmux new-window bash -lic '~/bosh-course-bootstrap/${project}/up.sh && sleep 10'
done
```

To bring the envrionments down run:
```
for project in $(ls student-env-*); do
  tmux new-window bash -lic '~/bosh-course-bootstrap/${project}/down.sh && sleep 10'
done
```
