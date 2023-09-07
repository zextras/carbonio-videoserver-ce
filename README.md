# Carbonio video server configuration

Compiler:                  gcc

libsrtp version:           2.x

SSL/crypto library:        OpenSSL

DTLS set-timeout:          not available

Mutex implementation:      GMutex (native futex on Linux)

DataChannels support:      yes

Recordings post-processor: yes

TURN REST API client:      no

Doxygen documentation:     no

JavaScript modules:        no

## Transports:

- REST (HTTP/HTTPS):     yes
- WebSockets:            yes
- RabbitMQ:              yes
- MQTT:                  no
- Unix Sockets:          no
- Nanomsg:               no

## Plugins:

- Echo Test:             no
- Streaming:             no
- Video Call:            no
- SIP Gateway:           no
- NoSIP (RTP Bridge):    no
- Audio Bridge:          yes
- Video Room:            yes
- Voice Mail:            no
- Record&Play:           no
- Text Room:             no
- Lua Interpreter:       no
- Duktape Interpreter:   no

## Event handlers:

- Sample event handler:  no
- WebSocket ev. handler: yes
- RabbitMQ event handler:yes
- MQTT event handler:    no
- Nanomsg event handler: no
- GELF event handler:    no

## External loggers:

- JSON file logger:      no

# License 📚

Video server component for Zextras Carbonio.

Released under the AGPL-3.0-only license as specified here: [COPYING](COPYING).

Copyright (C) 2022 Zextras <https://www.zextras.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, version 3 only of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

See [COPYING](COPYING) file for the project license details

See [THIRDPARTIES](THIRDPARTIES) file for other licenses details

## Copyright and Licensing notices

All non-software material (such as, for example, names, images, logos,
sounds) is owned by Zextras s.r.l. and is licensed under CC-BY-NC-SA
https://creativecommons.org/licenses/by-nc-sa/4.0/.
Where not specified, all source files owned by Zextras s.r.l. are licensed
under AGPL-3.0-only.
