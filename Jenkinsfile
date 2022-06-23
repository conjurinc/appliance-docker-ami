#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
    lock resource: "appliance-ami-creation"
  }

  parameters {
    string(
      name: 'IMAGE',
      description: 'Docker image to load into the AMI',
      defaultValue: 'registry.tld/conjur-appliance:5.0-stable'
    )
  }

  stages {
    stage('Create the AMI') {
      steps {
        sh "summon ./ebs_encryption.sh disable us-east-1"
        sh "./build-ami.sh ${params.IMAGE}"
        archiveArtifacts artifacts: 'AMI,ami-*', fingerprint: true
      }
      post {
        always {
          sh "summon ./ebs_encryption.sh enable us-east-1"
        }
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
