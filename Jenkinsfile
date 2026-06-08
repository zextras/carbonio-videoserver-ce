// SPDX-FileCopyrightText: 2025 Zextras <https://www.zextras.com>
//
// SPDX-License-Identifier: AGPL-3.0-only

library(
    identifier: 'jenkins-lib-common@dt3-pipeline',
    retriever: modernSCM([
        $class: 'GitSCMSource',
        credentialsId: 'jenkins-integration-with-github-account',
        remote: 'git@github.com:zextras/jenkins-lib-common.git',
    ])
)

dt3_pipeline(
    repoName: 'carbonio-videoserver-ce',
    packaging: [
        addCarbonioRepos: true,
        pkgbuildPaths: ['videoserver/videoserver/PKGBUILD', 'videoserver/videoserver-confs/PKGBUILD'],
        prepare: true,
    ],
    docker: [[
        dockerfile: 'videoserver/docker/Dockerfile',
        imageName: 'carbonio-videoserver-ce',
        title: 'Carbonio Videoserver CE',
        description: 'Carbonio Videoserver CE Service',
    ]],
    reuse: [projectType: 'CE'],
)
