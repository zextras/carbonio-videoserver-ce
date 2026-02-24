## [1.1.18](https://github.com/zextras/carbonio-videoserver-ce/compare/v1.1.17...v1.1.18) (2026-02-24)

### Bug Fixes

* Jenkins build updating upload artifacts stage ([#52](https://github.com/zextras/carbonio-videoserver-ce/issues/52)) ([fe80ab2](https://github.com/zextras/carbonio-videoserver-ce/commit/fe80ab218b39693e6dc53a25ae0f7688af043bce))
* PKGBUILD path in releaserc.json ([#55](https://github.com/zextras/carbonio-videoserver-ce/issues/55)) ([a351189](https://github.com/zextras/carbonio-videoserver-ce/commit/a351189927a7f2521be8cd70eb8d90ab8988c0da))
* PKGBUILD paths for both exec and git sections in releaserc.json ([#58](https://github.com/zextras/carbonio-videoserver-ce/issues/58)) ([79b5a77](https://github.com/zextras/carbonio-videoserver-ce/commit/79b5a7765a72486d9a195361497447d64d98ef64))

## [](https://github.com/zextras/carbonio-videoserver-ce/compare/v1.1.17...v) (2026-01-09)
## [1.1.17](https://github.com/zextras/carbonio-videoserver-ce/compare/1.1.5...v1.1.17) (2025-12-09)

### Features

* add ubuntu 24.04 (ubuntu-noble) support  ([#8](https://github.com/zextras/carbonio-videoserver-ce/issues/8)) ([5ca99ac](https://github.com/zextras/carbonio-videoserver-ce/commit/5ca99acdba58a5721fdd27fa105318a64032fad7))

### Bug Fixes

* add ampq check in the message-broker consul check to be sure it's ready ([#44](https://github.com/zextras/carbonio-videoserver-ce/issues/44)) ([7b187ef](https://github.com/zextras/carbonio-videoserver-ce/commit/7b187efce864d372ab9049af2eb65f3ff08a359d))
* **ci:** use variable substitution for credentials in auth.conf ([#33](https://github.com/zextras/carbonio-videoserver-ce/issues/33)) ([c91b042](https://github.com/zextras/carbonio-videoserver-ce/commit/c91b042fc614997ada3eab14103e980dfd0c07e6))
* remove executable permission on carbonio-videoserver.service ([#46](https://github.com/zextras/carbonio-videoserver-ce/issues/46)) ([8c21a44](https://github.com/zextras/carbonio-videoserver-ce/commit/8c21a440e72307d34b1f84ee9b2a30bb382b6426))
* revert WantedBy for compatibility with older systems ([#27](https://github.com/zextras/carbonio-videoserver-ce/issues/27)) ([19b6255](https://github.com/zextras/carbonio-videoserver-ce/commit/19b62556bb9a6749fd08117780c7d1dd8e330066))
* store api_secret value in the carbonio-videoserver script ([#16](https://github.com/zextras/carbonio-videoserver-ce/issues/16)) ([de5da89](https://github.com/zextras/carbonio-videoserver-ce/commit/de5da89d3aae4eda2a9a351ff029c14bb2a2f006))
## [1.1.5](https://github.com/zextras/carbonio-videoserver-ce/compare/1.1.4...1.1.5) (2024-06-21)
## [1.1.4](https://github.com/zextras/carbonio-videoserver-ce/compare/1.0.4...1.1.4) (2023-12-11)

### Features

* add consul and rabbitMQ integration ([85727a6](https://github.com/zextras/carbonio-videoserver-ce/commit/85727a65362a6cbab8bdc4be5e85da2b6b1d8e30))
* move to yap agent and add rhel9 support ([#17](https://github.com/zextras/carbonio-videoserver-ce/issues/17)) ([9314e79](https://github.com/zextras/carbonio-videoserver-ce/commit/9314e79b1a15465f44e09bb092fb7d6e0c9abf28))
* update janus.jcfg.patch for rabbitmq and http configuration files ([#10](https://github.com/zextras/carbonio-videoserver-ce/issues/10)) ([ebfa5f7](https://github.com/zextras/carbonio-videoserver-ce/commit/ebfa5f7fb595c0ca35aba86ec4b46db2087ee009))
* WSC-1003 update pre-commit-config yaml ([#9](https://github.com/zextras/carbonio-videoserver-ce/issues/9)) ([971f053](https://github.com/zextras/carbonio-videoserver-ce/commit/971f0535bb713f48e5769703e5bc7012d18848e4))

### Bug Fixes

* archiveArtifacts for Rocky8 package build ([c303b0e](https://github.com/zextras/carbonio-videoserver-ce/commit/c303b0ec7cc955193f7e33ddc1acafdef111e028))
* libvpx security mitigation for CVE-2023-5217 ([#13](https://github.com/zextras/carbonio-videoserver-ce/issues/13)) ([9b939b8](https://github.com/zextras/carbonio-videoserver-ce/commit/9b939b8c585e540f0f01e61df32b90233a2cffc9))
* rabbitmq plugin configuration for janus ([#4](https://github.com/zextras/carbonio-videoserver-ce/issues/4)) ([1199ada](https://github.com/zextras/carbonio-videoserver-ce/commit/1199adae949f1c546516447c4c89abfad7225ece))
* remove usage of carbonio-message-broker token ([#15](https://github.com/zextras/carbonio-videoserver-ce/issues/15)) ([26723b1](https://github.com/zextras/carbonio-videoserver-ce/commit/26723b1b97f04f7eda8176c6e176d37bc9895b07))
* ws-collaboration intention ([#5](https://github.com/zextras/carbonio-videoserver-ce/issues/5)) ([4c15ef9](https://github.com/zextras/carbonio-videoserver-ce/commit/4c15ef983c977eb9f2d78ff1350bd1fae5b9c48a))

### Reverts

* Revert "Bump videoserver to 0.10.6 (internal versioning)" ([4a949af](https://github.com/zextras/carbonio-videoserver-ce/commit/4a949af3486a115ea0d39f722426ff6df75a28a4))
* Revert "Merged in feature/TEAMS-2673-align-video-servers-port-to-t (pull request #3)" ([3bb4e9b](https://github.com/zextras/carbonio-videoserver-ce/commit/3bb4e9b83e1916d8f0a6a54895c6646a1f118981)), closes [#3](https://github.com/zextras/carbonio-videoserver-ce/issues/3)
## [1.0.4](https://github.com/zextras/carbonio-videoserver-ce/compare/0.11.8...1.0.4) (2023-01-20)
## [0.11.8](https://github.com/zextras/carbonio-videoserver-ce/compare/22672a36bb6d3580ffc5aa973ebb9eb94bc64c5f...0.11.8) (2022-05-25)

### Features

* **ci:** add 20 focal fossa support ([bb1821e](https://github.com/zextras/carbonio-videoserver-ce/commit/bb1821e73beb9dc756f9a8f14cc3a6c4390d62d4))

### Bug Fixes

* **ci:** commented out centos-8 cause of EOL ([a6a5fe6](https://github.com/zextras/carbonio-videoserver-ce/commit/a6a5fe6c16b144a5d6d6093beabb6b5f06cc0888))

### Reverts

* Revert "Merged in feature/TEAMS-2673-align-video-servers-port-to-t (pull request #3)" ([22672a3](https://github.com/zextras/carbonio-videoserver-ce/commit/22672a36bb6d3580ffc5aa973ebb9eb94bc64c5f)), closes [#3](https://github.com/zextras/carbonio-videoserver-ce/issues/3)
