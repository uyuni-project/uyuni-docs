pipeline {
  agent any
  stages {
    stage('Build/Publish Docs') {
      steps {
        sh '''git checkout gh-pages
rm -rf *
git clone git@github.com:uyuni-project/uyuni-docs-publisher.git
cd uyuni-docs-publisher
docker run -u $UID -v `pwd`:/antora --rm -t registry.mgr.suse.de/antora --cache-dir=./.cache/antora uyuni-publisher.yml\'
cp -r public/* ../
cd ..
git status
git add .
git commit -am "doc-ci-update"
git push

'''
      }
    }
  }
}