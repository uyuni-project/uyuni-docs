pipeline {
  agent any
  stages {
    stage('Clone repo') {
      steps {
        echo 'Cloning publisher repo'
        sh '''rm -rf uyuni-docs-publisher
git clone https://github.com/uyuni-project/uyuni-docs-publisher
cd uyuni-docs-publisher
'''
      }
    }
    stage('Run Antora') {
      steps {
        sh '''cd uyuni-docs-publisher

docker run -u $UID -v `pwd`:/antora --rm -t registry.mgr.suse.de/antora --cache-dir=./.cache antora uyuni-publisher.yml

cd ..'''
      }
    }
  }
}