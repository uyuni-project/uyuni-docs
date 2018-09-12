pipeline {
  agent {
    docker {
      image 'registry.mgr.suse.de/antora'
    }

  }
  stages {
    stage('Pull') {
      agent {
        docker {
          image 'registry.mgr.suse.de/antora'
        }

      }
      steps {
        echo 'running script'
        sh '''#!/bin/bash
git clone https://github.com/uyuni-project/uyuni-docs-publisher && cd uyuni-docs-publisher
docker run -u $UID -v `pwd`:/antora --rm -t registry.mgr.suse.de/antora --cache-dir=./.cache/antora uyuni-publisher.yml && cd ..
git clone https://github.com/uyuni-project/uyuni-docs && cd uyuni-docs && git checkout gh-pages
rm -rf *
cp -r ../uyuni-docs-publisher/public/* .
git status && git add . && git commit -am "doc-ci-update" && git push
'''
      }
    }
  }
}