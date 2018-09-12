pipeline {
  agent {
    docker {
      image 'registry.mgr.suse.de/antora'
    }

  }
  stages {
    stage('Build') {
      agent {
        docker {
          image 'registry.mgr.suse.de/antora'
        }

      }
      steps {
        sh '''clone https://github.com/uyuni-project/uyuni-docs-publisher
cd uyuni-docs-publisher
'''
      }
    }
  }
}