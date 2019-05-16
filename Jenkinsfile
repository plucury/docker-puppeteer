pipeline {
  agent {
    label "jenkins-nodejs"
  }
  environment {
    ORG = 'AriesApp'
    APP_NAME = 'docker-puppeteer'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
  }
  parameters {
    booleanParam(name: 'DEPLOY_PRODUCTION', defaultValue: false, description: '')
    booleanParam(name: 'DEPLOY_DEVELOPMENT', defaultValue: false, description: '')
    string(name: 'DEPLOY_VERSION', defaultValue: '', description: 'If $DEPLOY_VERSION is empty, build the master and deploy it')
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('nodejs') {
          sh "npm install"
          sh "CI=true DISPLAY=:99 npm test"
          sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          dir('./charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    stage('Build Release') {
      when {
        branch 'master'
        equals expected: '', actual: params.DEPLOY_VERSION
      }
      steps {
        container('nodejs') {

          // ensure we're not on a detached head
          sh "git checkout master"
          sh "git config --global credential.helper store"
          sh "jx step git credentials"

          // so we can retrieve the version in later steps
          sh "echo \$(jx-release-version) > VERSION"
          sh "jx step tag --version \$(cat VERSION)"
          sh "npm install"
          sh "CI=true DISPLAY=:99 npm test"
          sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
        }
      }
    }
    stage('Promote to Environments') {
      when {
        branch 'master'
        equals expected: '', actual: params.DEPLOY_VERSION
      }
      steps {
        container('nodejs') {
          dir('./charts/docker-puppeteer') {
            sh "jx step changelog --batch-mode --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all 'Auto' promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
        }
      }
    }
       stage('Deploy to Production'){
      when {
        branch 'master'
        equals expected: true, actual: params.DEPLOY_PRODUCTION
      }
      steps {
        container('nodejs') {
           dir('./charts/docker-puppeteer'){
             script {
              if(params.DEPLOY_VERSION != ''){
                sh "jx promote --version ${params.DEPLOY_VERSION} --env production --timeout 1h --batch-mode"
              }else{
                sh "jx promote --version \$(cat ../../VERSION) --env production --timeout 1h --batch-mode"
              }
            }
           }
        }
      }
    }
    stage('Deploy to Development'){
      when {
        branch 'master'
        equals expected: true, actual: params.DEPLOY_DEVELOPMENT
      }
      steps {
        container('nodejs') {
           dir('./charts/docker-puppeteer'){
             script {
              if(params.DEPLOY_VERSION != ''){
                sh "jx promote --version ${params.DEPLOY_VERSION} --env development --timeout 1h --batch-mode"
              }else{
                sh "jx promote --version \$(cat ../../VERSION) --env development --timeout 1h --batch-mode"
              }
             }
           }
        }
      }
    }
  }
  post {
        always {
          cleanWs()
        }
  }
}
