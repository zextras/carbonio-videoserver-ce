pipeline {
	agent {
		node {
			label 'base-agent-v1'
		}
	}
	options {
		buildDiscarder(logRotator(numToKeepStr: '5'))
		timeout(time: 1, unit: 'HOURS')
	}
	environment {
		NETWORK_OPTS = "--network ci_agent"
		WORKSPACE = pwd()
	}
	stages {
		stage('Checkout building resources') {
			parallel {
				stage('Build script checkout') {
					steps {
						dir('janus-builder') {
							git branch: 'master',
								credentialsId: 'tarsier_bot-ssh-key',
								url: 'git@bitbucket.org:zextras/janus-builder.git'
						}
					}
				}
				stage('Zimbra STUB checkout') {
					steps {
						sh 'pwd'
						dir('zimbra-package-stub') {
							git branch: 'zimbra/9.0.0p3',
								credentialsId: 'tarsier_bot-ssh-key',
								url: 'git@bitbucket.org:zextras/zimbra-package-stub.git'
						}
					}
				}
			}
		}
		stage('Building Janus...') {
			parallel {
				stage('Ubuntu 18.04') {
					steps {
						sh 'cd janus-builder; ./build_ubuntu18'
						script {
							env.CONTAINER1_ID = sh(returnStdout: true, script: 'docker run -dt ${NETWORK_OPTS} janus-builder-ubuntu18').trim()
						}
						sh "docker cp ${WORKSPACE} ${env.CONTAINER1_ID}:/u18"
						sh "docker exec -t ${env.CONTAINER1_ID} bash -c \"cd /u18/; ./build.sh\""
						sh "docker cp ${env.CONTAINER1_ID}:/u18/artifacts/. ${WORKSPACE}"
						script {
							def server = Artifactory.server 'zextras-artifactory'
							def buildInfo = Artifactory.newBuildInfo()

							def uploadSpec = """{
								"files": [
									{
										"pattern": "videoserver*/*.deb",
										"target": "debian-local/pool/",
										"props": "deb.distribution=bionic;deb.component=main;deb.architecture=amd64"
									}
								]
							}"""
							server.upload spec: uploadSpec, buildInfo: buildInfo
							server.publishBuildInfo buildInfo
						}
					}
					post {
						success {
							archiveArtifacts artifacts: "*.tgz", fingerprint: true
						}
						always {
							sh "docker kill ${env.CONTAINER1_ID}"
						}
					}
				}
				stage('Ubuntu 20.04') {
					steps {
						sh 'cd janus-builder; ./build_ubuntu20'
						script {
							env.CONTAINER5_ID = sh(returnStdout: true, script: 'docker run -dt ${NETWORK_OPTS} janus-builder-ubuntu20').trim()
						}
						sh "docker cp ${WORKSPACE} ${env.CONTAINER5_ID}:/u20"
						sh "docker exec -t ${env.CONTAINER5_ID} bash -c \"cd /u20/; ./build.sh\""
						sh "docker cp ${env.CONTAINER5_ID}:/u20/artifacts/. ${WORKSPACE}"
						script {
							def server = Artifactory.server 'zextras-artifactory'
							def buildInfo = Artifactory.newBuildInfo()

							def uploadSpec = """{
								"files": [
									{
										"pattern": "videoserver*/*.deb",
										"target": "debian-local/pool/",
										"props": "deb.distribution=focal;deb.component=main;deb.architecture=amd64"
									}
								]
							}"""
							server.upload spec: uploadSpec, buildInfo: buildInfo
							server.publishBuildInfo buildInfo
						}
					}
					post {
						success {
							archiveArtifacts artifacts: "*.tgz", fingerprint: true
						}
						always {
							sh "docker kill ${env.CONTAINER5_ID}"
						}
					}
				}                   
				stage('CentOS 7') {
					steps {
						sh 'cd janus-builder; ./build_centos7'
						script {
							env.CONTAINER2_ID = sh(returnStdout: true, script: 'docker run -dt ${NETWORK_OPTS} janus-builder-centos7').trim()
						}
						sh "docker cp ${WORKSPACE} ${env.CONTAINER2_ID}:/r7"
						sh "docker exec -t ${env.CONTAINER2_ID} bash -c \"cd /r7/; scl enable devtoolset-9 ./build.sh\""
						sh "docker cp ${env.CONTAINER2_ID}:/r7/artifacts/. ${WORKSPACE}"
						script {
							def server = Artifactory.server 'zextras-artifactory'
							def buildInfo = Artifactory.newBuildInfo()

							def uploadSpec = """{
								"files": [
									{
										"pattern": "videoserver*/(*)-(*)-(*).rpm",
										"target": "rpm-local/zextras/{1}/{1}-{2}-{3}.rpm",
										"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=Zextras"
									}
								]
							}"""
							server.upload spec: uploadSpec, buildInfo: buildInfo
							server.publishBuildInfo buildInfo
						}
					}
					post {
						success {
							archiveArtifacts artifacts: "*.tgz", fingerprint: true
						}
						always {
							sh "docker kill ${env.CONTAINER2_ID}"
						}
					}
				}
				stage('CentOS 8') {
					steps {
						sh 'cd janus-builder; ./build_centos8'
						script {
							env.CONTAINER3_ID = sh(returnStdout: true, script: 'docker run -dt ${NETWORK_OPTS} janus-builder-centos8').trim()
						}
						sh "docker cp ${WORKSPACE} ${env.CONTAINER3_ID}:/r8"
						sh "docker exec -t ${env.CONTAINER3_ID} bash -c \"cd /r8/; ./build.sh\""
						sh "docker cp ${env.CONTAINER3_ID}:/r8/artifacts/. ${WORKSPACE}"
						script {
							def server = Artifactory.server 'zextras-artifactory'
							def buildInfo = Artifactory.newBuildInfo()

							def uploadSpec = """{
								"files": [
									{
										"pattern": "videoserver*/(*)-(*)-(*).rpm",
										"target": "rpm-local/zextras/{1}/{1}-{2}-{3}.rpm",
										"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=Zextras"
									}
								]
							}"""
							server.upload spec: uploadSpec, buildInfo: buildInfo
							server.publishBuildInfo buildInfo
						}
					}
					post {
						success {
							archiveArtifacts artifacts: "*.tgz", fingerprint: true
						}
						always {
							sh "docker kill ${env.CONTAINER3_ID}"
						}
					}
				}
			}
		}
	}
	post {
		success {
			build job: 'Bitbucket Cloud/zextras/janus-installer/master',
				parameters: [
				string(name: 'janusParamName', value: "${BRANCH_NAME}")
			], propagate: false
		}        
		always {
			sh 'docker rmi janus-builder-ubuntu18 --force'
			sh 'docker rmi janus-builder-ubuntu20 --force'
			sh 'docker rmi janus-builder-centos7 --force'
			sh 'docker rmi janus-builder-centos8 --force'

			script {
				GIT_COMMIT_EMAIL = sh(
					script: 'git --no-pager show -s --format=\'%ae\'',
					returnStdout: true
				).trim()
			}
			emailext attachLog: true, body: '$DEFAULT_CONTENT', recipientProviders: [requestor()], subject: '$DEFAULT_SUBJECT', to: "${GIT_COMMIT_EMAIL}"
		}
	}
}
