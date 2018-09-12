pipeline {
  agent any
  stages {
    stage('Build') {
      agent {
        docker {
          image 'registry.mgr.suse.de/antora'
        }

      }
      steps {
        sh 'echo PATH =${PATH}'
      }
    }
  }
}