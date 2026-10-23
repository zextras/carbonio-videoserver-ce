// SPDX-FileCopyrightText: 2025 Zextras <https://www.zextras.com>
//
// SPDX-License-Identifier: AGPL-3.0-only

library(
    identifier: 'jenkins-lib-common@v5.1.0',
    retriever: modernSCM([
        $class: 'GitSCMSource',
        credentialsId: 'jenkins-integration-with-github-account',
        remote: 'git@github.com:zextras/jenkins-lib-common.git',
    ])
)

dt3_pipeline(
    repoName: 'carbonio-videoserver-ce',
    packaging: [
        pkgbuildPaths: ['videoserver/videoserver/PKGBUILD'],
        addCarbonioRepos: true,
        prepare: true,
        aarch64: true,
        artifactsForDocker: true,
    ],
    docker: [
        [
            dockerfile: 'videoserver/docker/Dockerfile',
            imageName: 'carbonio-videoserver-ce',
            platforms: ['linux/amd64', 'linux/arm64'] as Set,
            title: 'Carbonio Videoserver CE',
            description: 'Carbonio Videoserver CE Service',
        ],
        [
            dockerfile: 'videoserver/docker/videoserver-sidecar/Dockerfile',
            imageName: 'carbonio-videoserver-ce-sidecar',
            platforms: ['linux/amd64', 'linux/arm64'] as Set,
            title: 'Carbonio Videoserver CE Sidecar',
            description: 'Carbonio Videoserver Community Edition Sidecar',
        ],
    ],
    reuse: [projectType: 'CE'],
)
