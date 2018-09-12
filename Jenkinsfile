pipeline {
  agent any
  stages {
    stage('Clone repo') {
      steps {
        echo 'Cloning publisher repo'
        sh '''git clone https://github.com/uyuni-project/uyuni-docs-publisher
cd uyuni-docs-publisher
'''
      }
    }
  }
}