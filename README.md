<h1 align="center">Carbonio VideoServer CE 🚀</h1>

<div align="center">
VideoServer service for Zextras Carbonio

[![Contributors][contributors-badge]][contributors]
[![Activity][activity-badge]][activity]
[![License][license-badge]](COPYING)
[![Project][project-badge]][project]
[![Twitter][twitter-badge]][twitter]

</div>

***

## How to install 🏁

### Installation

Install `carbonio-videoserver-ce` via apt:

```bash
sudo apt install carbonio-videoserver-ce
```

or via yum:

 ```bash
sudo yum install carbonio-videoserver-ce
```

### Configuration

- Execute `pending-setups` in order to register the service in
  the `service-discover`
- You need to set the `nat_1_1_mapping` config parameter in the
  `/etc/janus/janus.jcfg` with the public IP of the node where
  carbonio-videoserver-ce has been installed in order to let clients to
  connect with it properly. If you do that, please remember to restart the
  service: `systemctl restart carbonio-videoserver`

***

## License 📚

Video server component for Zextras Carbonio.

Released under the AGPL-3.0-only license as specified here: [COPYING](COPYING).

Copyright (C) 2022 Zextras <https://www.zextras.com>

> This program is free software: you can redistribute it and/or modify
> it under the terms of the GNU Affero General Public License as published by
> the Free Software Foundation, version 3 only of the License.
>
> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> GNU Affero General Public License for more details.
>
> You should have received a copy of the GNU Affero General Public License
> along with this program.  If not, see <https://www.gnu.org/licenses/>.

See [COPYING](COPYING) file for the project license details

See [THIRDPARTIES](THIRDPARTIES) file for other licenses details

## Copyright and Licensing notices

All non-software material (such as, for example, names, images, logos,
sounds) is owned by Zextras and is licensed under CC-BY-NC-SA
https://creativecommons.org/licenses/by-nc-sa/4.0/.
Where not specified, all source files owned by Zextras are licensed
under AGPL-3.0-only.
