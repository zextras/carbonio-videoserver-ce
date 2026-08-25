// SPDX-FileCopyrightText: 2025 Zextras <https://www.zextras.com>
//
// SPDX-License-Identifier: AGPL-3.0-only

library(
    identifier: 'jenkins-lib-common@v4.9.1',
    retriever: modernSCM([
        $class: 'GitSCMSource',
        credentialsId: 'jenkins-integration-with-github-account',
        remote: 'git@github.com:zextras/jenkins-lib-common.git',
    ])
)

properties(defaultPipelineProperties())

pipeline {
    agent {
        node {
            label 'base'
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '25'))
        skipDefaultCheckout()
        timeout(time: 2, unit: 'HOURS')
    }

    stages {
        stage('Setup') {
            steps {
                checkout scm
                script {
                    gitMetadata()
                }
            }
        }

        stage('Skip CI') {
            steps {
                script {
                    semanticRelease.guard()
                }
            }
        }

        stage('Build deb/rpm') {
            steps {
                echo 'Building deb/rpm packages'
                buildStage(
                    addCarbonioRepos: true,
                    prepare: true,
                    rockySinglePkg: false,
                    ubuntuSinglePkg: false,
                )
                buildStage(
                    addCarbonioRepos: true,
                    architecture: 'aarch64',
                    distros: ['ubuntu-jammy'],
                    parallelBuilds: false,
                    prepare: true,
                )
            }
        }

        stage('Upload artifacts') {
            when {
                expression { return uploadStage.shouldUpload() }
            }
            tools {
                jfrog 'jfrog-cli'
            }
            steps {
                uploadStage(
                    rockySinglePkg: false,
                    ubuntuSinglePkg: false,
                )
                uploadStage(
                    architecture: 'aarch64',
                    distros: ['ubuntu-jammy'],
                )
            }
        }

        stage('Publish docker images') {
            steps {
                unstash 'artifacts-ubuntu-jammy'
                unstash 'artifacts-ubuntu-jammy-aarch64'
                dockerStage(
                    images: [[
                        dockerfile: 'videoserver/docker/Dockerfile',
                        imageName: 'carbonio-videoserver-ce',
                        platforms: ['linux/amd64', 'linux/arm64'] as Set,
                        ocLabels: [
                            title: 'Carbonio Videoserver CE',
                            description: 'Carbonio Videoserver CE Service',
                        ],
                    ]]
                )
            }
        }

        stage('Semantic Release') {
            steps {
                semanticRelease()
            }
        }
    }
}
