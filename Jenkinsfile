pipeline {
  agent any
  stages {
    stage('Clone Publisher') {
      parallel {
        stage('Build') {
          agent {
            docker {
              image 'registry.mgr.suse.de/antora'
            }

          }
          steps {
            echo 'Cloning uyuni-docs-publisher'
            sh '''git clone https://github.com/uyuni-project/uyuni-docs-publisher && cd uyuni-docs-publisher
'''
          }
        }
        stage('Run antora') {
          steps {
            echo 'Building docs with antora'
            sh '''docker run -u $UID -v `pwd`:/antora --rm -t registry.mgr.suse.de/antora --cache-dir=./.cache/antora uyuni-publisher.yml
'''
          }
        }
        stage('Clone Docs') {
          steps {
            echo 'Cloning Docs'
            sh '''git clone https://github.com/uyuni-project/uyuni-docs && cd uyuni-docs 

'''
            echo 'Checking out gh-pages'
            sh 'git checkout gh-pages'
          }
        }
      }
    }
  }
}