pipeline {
  agent any
  stages {
    stage('Run Antora') {
      steps {
        echo 'Cloning publisher repo'
        sh '''rm -rf uyuni-docs-publisher


'''
        sh 'git clone https://github.com/uyuni-project/uyuni-docs-publisher'
        sh 'cd uyuni-docs-publisher'
        sh 'docker run -u $UID -v `pwd`:/antora --rm -t registry.mgr.suse.de/antora --cache-dir=./.cache/antora uyuni-publisher.yml'
      }
    }
  }
}