// SPDX-FileCopyrightText: 2023 Zextras <https://www.zextras.com>
//
// SPDX-License-Identifier: AGPL-3.0-only

library(
  identifier: 'jenkins-lib-common@1.1.2',
  retriever: modernSCM([
    $class: 'GitSCMSource',
    credentialsId: 'jenkins-integration-with-github-account',
    remote: 'git@github.com:zextras/jenkins-lib-common.git'
  ])
)

pipeline {
  agent {
    node {
      label 'zextras-v1'
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    skipDefaultCheckout()
    timeout(time: 1, unit: 'HOURS')
  }

  stages {
    stage('Setup') {
      steps {
        checkout scm
        script {
          gitMetadata()
          properties(defaultPipelineProperties())
        }
      }
    }

    stage('Publish docker image') {
      steps {
        dockerStage([
          dockerfile: 'videoserver/docker/Dockerfile',
          imageName: 'registry.dev.zextras.com/dev/carbonio-videoserver-ce',
          ocLabels: [
            title: 'Carbonio Videoserver CE',
            descriptionFile: 'videoserver/docker/description.md',
            version: env.GIT_TAG ?: 'devel',
          ]
        ])
      }
    }

    stage('Build deb/rpm') {
      steps {
        echo 'Building deb/rpm packages'
        withCredentials([
          usernamePassword(
            credentialsId: 'artifactory-jenkins-gradle-properties-splitted',
            passwordVariable: 'SECRET',
            usernameVariable: 'USERNAME'
          )
        ]) {
          script {
            env.REPO_ENV = env.GIT_TAG ? 'rc' : 'devel'
          }

          buildStage([
            prepare: true,
            overrides: [
              'ubuntu-jammy': [
                preBuildScript: '''
                  echo "machine zextras.jfrog.io" >> auth.conf
                  echo "login $USERNAME" >> auth.conf
                  echo "password $SECRET" >> auth.conf
                  mv auth.conf /etc/apt
                  echo "deb [trusted=yes] https://zextras.jfrog.io/artifactory/ubuntu-''' + env.REPO_ENV + ''' jammy main" > zextras.list
                  mv *.list /etc/apt/sources.list.d/
                '''
              ],
              'ubuntu-noble': [
                preBuildScript: '''
                  echo "machine zextras.jfrog.io" >> auth.conf
                  echo "login $USERNAME" >> auth.conf
                  echo "password $SECRET" >> auth.conf
                  mv auth.conf /etc/apt
                  echo "deb [trusted=yes] https://zextras.jfrog.io/artifactory/ubuntu-''' + env.REPO_ENV + ''' noble main" > zextras.list
                  mv *.list /etc/apt/sources.list.d/
                '''
              ],
              'rocky-8': [
                preBuildScript: '''
                  echo "[Zextras]" > zextras.repo
                  echo "name=Zextras" >> zextras.repo
                  echo "baseurl=https://$USERNAME:$SECRET@zextras.jfrog.io/artifactory/centos8-''' + env.REPO_ENV + '''/" >> zextras.repo
                  echo "enabled=1" >> zextras.repo
                  echo "gpgcheck=0" >> zextras.repo
                  echo "gpgkey=https://$USERNAME:$SECRET@zextras.jfrog.io/artifactory/centos8-''' + env.REPO_ENV + '''/repomd.xml.key" >> zextras.repo
                  mv *.repo /etc/yum.repos.d/
                ''',
              ],
              'rocky-9': [
                preBuildScript: '''
                  echo "[Zextras]" > zextras.repo
                  echo "name=Zextras" >> zextras.repo
                  echo "baseurl=https://$USERNAME:$SECRET@zextras.jfrog.io/artifactory/rhel9-''' + env.REPO_ENV + '''/" >> zextras.repo
                  echo "enabled=1" >> zextras.repo
                  echo "gpgcheck=0" >> zextras.repo
                  echo "gpgkey=https://$USERNAME:$SECRET@zextras.jfrog.io/artifactory/rhel9-''' + env.REPO_ENV + '''/repomd.xml.key" >> zextras.repo
                  mv *.repo /etc/yum.repos.d/
                ''',
              ],
            ]
          ])
        }
      }
    }

    stage('Upload artifacts')
    {
      tools {
        jfrog 'jfrog-cli'
      }
      steps {
        uploadStage([
          packages: yapHelper.resolvePackageNames()
        ])
      }
    }
  }
}
