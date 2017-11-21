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
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
