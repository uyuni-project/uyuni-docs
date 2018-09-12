pipeline {
  agent any
  stages {
    stage('Clone repo') {
      steps {
        echo 'Cloning publisher repo'
        sh '''sh git clone https://github.com/uyuni-project/uyuni-docs-publisher
sh cd uyuni-docs-publisher
'''
      }
    }
  }
}