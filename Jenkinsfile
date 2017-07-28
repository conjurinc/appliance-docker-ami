#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  parameters {
    string(
      name: 'IMAGE',
      description: 'Docker image to load into the AMI',
      defaultValue: 'registry.tld/conjur-appliance:4.9-stable'
    )
  }

  stages {
    stage('Create the AMI') {
      steps {
        sh "./build-ami.sh ${params.IMAGE}"
        archiveArtifacts artifacts: 'AMI,ami-*', fingerprint: true
      }
    }

    stage('Smoke test the AMI') {
      steps {
        sh './test.sh $(cat AMI)'
      }
    }
  }

  post {
    always {
      deleteDir()  // delete current workspace, for a clean build
    }
    failure {
      slackSend(color: 'danger', message: "${env.JOB_NAME} #${env.BUILD_NUMBER} FAILURE (<${env.BUILD_URL}|Open>)")
    }
    unstable {
      slackSend(color: 'warning', message: "${env.JOB_NAME} #${env.BUILD_NUMBER} UNSTABLE (<${env.BUILD_URL}|Open>)")
    }
  }
}
