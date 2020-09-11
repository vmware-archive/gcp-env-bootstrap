#!/usr/bin/env groovy

def execAll(multilineCmd) {
  multilineCmd.split('\n').each { cmd ->
    if (cmd?.trim()) {
      execIt(cmd)
    }
  }
}
def execIt(cmd) {
  println "cmd: $cmd"

  def p = new ProcessBuilder('sh', '-c', cmd)
      .redirectErrorStream(true)
      .start()

  def result = p.inputStream.readLines()

  p.waitFor()
  if (p.exitValue() != 0) {
    throw new RuntimeException("cmd execution ($cmd) failed")
  }

  result
}

execIt("gcloud projects list --filter='name:pasfun-0907-*' --format='value(project_id)'").each {
  def deleteCmd = "gcloud projects delete ${it} --quiet"
  execIt deleteCmd
}

/* todo:

- obtain cohort folder
  def cohortFolderId = 
    execIt "gcloud resource-manager folders list --folder 104897317919 --filter='display_name:cohort-${cohort_id}' --format='value(ID)''"
- list projects under the cohort folder instead of by name prefix
- delete projects under cohort folder
- delete cohort folder
  execIt "gcloud resource-manager folders delete ${cohortFolderId}"
- parameterize cohort id as command line argument

*/