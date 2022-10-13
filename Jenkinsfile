pipeline {
	parameters {
		booleanParam defaultValue: false, description: 'Whether to upload the packages in devel repositories', name: 'DEVEL'
	}
	options {
		skipDefaultCheckout()
		buildDiscarder(logRotator(numToKeepStr: '5'))
		timeout(time: 1, unit: 'HOURS')
	}
	agent {
		node {
			label 'base-agent-v1'
		}
	}
	environment {
		NETWORK_OPTS = '--network ci_agent'
	}
	stages {
		stage('Checkout & Stash') {
			agent {
				node {
					label 'base-agent-v1'
				}
			}
			steps {
				checkout scm
				stash includes: '**', name: 'project'
			}
		}
		stage('Packaging') {
			parallel {
				stage('Ubuntu 20') {
					agent {
						node {
							label 'pacur-agent-ubuntu-20.04-v1'
						}
					}
					steps {
						unstash 'project'
						sh 'sudo pacur build ubuntu-focal videoserver'
						stash includes: 'artifacts/', name: 'artifacts-ubuntu-focal'
					}
					post {
						always {
							archiveArtifacts artifacts: 'artifacts/*.deb', fingerprint: true
						}
					}
				}
			}
		}
		stage('Upload To Devel') {
			when {
				anyOf {
					expression { params.DEVEL == true }
				}
			}
			steps {
				unstash 'artifacts-ubuntu-focal'
				script {
					def server = Artifactory.server 'zextras-artifactory'
					def buildInfo
					def uploadSpec
					buildInfo = Artifactory.newBuildInfo()
					uploadSpec = '''{
						"files": [
							{
								"pattern": "artifacts/*.deb",
								"target": "ubuntu-devel/pool/",
								"props": "deb.distribution=focal;deb.component=main;deb.architecture=amd64"
							},
						   {
								"pattern": "artifacts/(zimbra-ffmpeg)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libev)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libfdk-aac)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libnice)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libopus)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libsrtp)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libusrsctp)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libuv)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libvpx)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libwebsockets)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-videoserver)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-videoserver-confs)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-x264)-(*).rpm",
								"target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							}
						]
					}'''
					server.upload spec: uploadSpec, buildInfo: buildInfo, failNoOp: false
				}
			}
		}
		stage('Upload & Promotion Config') {
			when {
				buildingTag()
			}
			steps {
				unstash 'artifacts-ubuntu-bionic'
				unstash 'artifacts-ubuntu-focal'
				unstash 'artifacts-rocky-8'

				script {
					def server = Artifactory.server 'zextras-artifactory'
					def buildInfo
					def uploadSpec
					def config

					//ubuntu
					buildInfo = Artifactory.newBuildInfo()
					buildInfo.name += '-ubuntu'
					uploadSpec = '''{
						"files": [
							{
								"pattern": "artifacts/*bionic*.deb",
								"target": "ubuntu-rc/pool/",
								"props": "deb.distribution=bionic;deb.component=main;deb.architecture=amd64"
							},
							{
								"pattern": "artifacts/*focal*.deb",
								"target": "ubuntu-rc/pool/",
								"props": "deb.distribution=focal;deb.component=main;deb.architecture=amd64"
							}
						]
					}'''
					server.upload spec: uploadSpec, buildInfo: buildInfo, failNoOp: false
					config = [
							'buildName'          : buildInfo.name,
							'buildNumber'        : buildInfo.number,
							'sourceRepo'         : 'ubuntu-rc',
							'targetRepo'         : 'ubuntu-release',
							'comment'            : 'Do not change anything! Just press the button',
							'status'             : 'Released',
							'includeDependencies': false,
							'copy'               : true,
							'failFast'           : true
					]
					Artifactory.addInteractivePromotion server: server, promotionConfig: config, displayName: 'Ubuntu Promotion to Release'
					server.publishBuildInfo buildInfo

					//rocky8
					buildInfo = Artifactory.newBuildInfo()
					buildInfo.name += "-centos8"
					uploadSpec = '''{
						"files": [
							{
								"pattern": "artifacts/(zimbra-ffmpeg)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libev)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libfdk-aac)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libnice)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libopus)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libsrtp)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libusrsctp)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libuv)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libvpx)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-libwebsockets)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-videoserver)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-videoserver-confs)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							},
							{
								"pattern": "artifacts/(zimbra-x264)-(*).rpm",
								"target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
								"props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
							}
						]
					}'''

					server.upload spec: uploadSpec, buildInfo: buildInfo, failNoOp: false
					config = [
							'buildName'          : buildInfo.name,
							'buildNumber'        : buildInfo.number,
							'sourceRepo'         : 'centos8-rc',
							'targetRepo'         : 'centos8-release',
							'comment'            : 'Do not change anything! Just press the button',
							'status'             : 'Released',
							'includeDependencies': false,
							'copy'               : true,
							'failFast'           : true
					]
					Artifactory.addInteractivePromotion server: server, promotionConfig: config, displayName: "Centos8 Promotion to Release"
					server.publishBuildInfo buildInfo
				}
			}
		}
	}
}

