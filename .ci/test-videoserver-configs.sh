#!/bin/bash

# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

set -e

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
CONFIGS="$REPO_ROOT/videoserver/videoserver/carbonio-videoserver-configs"
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
mkdir "$TEST_DIR/bin" "$TEST_DIR/janus"

export JANUS_CONF_DIR="$TEST_DIR/janus"
JANUS_CFG="$JANUS_CONF_DIR/janus.jcfg"
EVH_CFG="$JANUS_CONF_DIR/janus.eventhandler.rabbitmqevh.jcfg"

cat >"$JANUS_CFG.sample" <<'EOF'
general: {
	api_secret = "${API_SECRET}"	# String that all Janus requests must contain
}
nat: {
	nat_1_1_mapping = "${PUBLIC_IP_ADDRESS}"
	#keep_private_host = true
}
EOF
cat >"$EVH_CFG.sample" <<'EOF'
general: {
	username = "<RABBITMQ_USERNAME>"				# Username to use to authenticate, if needed
	password = "<RABBITMQ_PASSWORD>"				# Password to use to authenticate, if needed
}
EOF

cat >"$TEST_DIR/bin/consul" <<'EOF'
#!/bin/sh
value() { [ -n "$1" ] && printf '%s\n' "$1"; }
case "$*" in
  "kv get "*" carbonio-videoserver/api-secret") value "$STUB_API_SECRET" ;;
  "kv get "*" carbonio-message-broker/default/username") value "$STUB_RABBITMQ_USERNAME" ;;
  "kv get "*" carbonio-message-broker/default/password") value "$STUB_RABBITMQ_PASSWORD" ;;
  "kv put "*) printf '%s\n' "$*" >>"$STUB_CONSUL_PUTS" ;;
  *) exit 1 ;;
esac
EOF
cat >"$TEST_DIR/bin/curl" <<'EOF'
#!/bin/sh
[ -n "$STUB_PUBLIC_IP" ] && printf '%s' "$STUB_PUBLIC_IP"
EOF
chmod +x "$TEST_DIR/bin/consul" "$TEST_DIR/bin/curl"

export PATH="$TEST_DIR/bin:$PATH"
export STUB_CONSUL_PUTS="$TEST_DIR/consul-puts"
export STUB_API_SECRET='api/secret+=='
export STUB_RABBITMQ_USERNAME='janus'
export STUB_RABBITMQ_PASSWORD='pa/ss&w|o"rd\x'
export STUB_PUBLIC_IP='203.0.113.7'

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_contains() {
  grep -Fq -- "$2" "$1" || fail "$(basename "$1") does not contain: $2"
}

assert_matches() {
  grep -Eq -- "$2" "$1" || fail "$(basename "$1") does not match: $2"
}

edit() {
  sed -e "$2" "$1" >"$1.edit" && mv "$1.edit" "$1"
}

file_mode() {
  stat -c '%a' "$1" 2>/dev/null || stat -f '%Lp' "$1"
}

# Fresh install: credentials from Consul, public IP detected.
"$CONFIGS"
assert_contains "$JANUS_CFG" 'api_secret = "api/secret+=="'
assert_contains "$JANUS_CFG" 'nat_1_1_mapping = "203.0.113.7"'
assert_matches "$JANUS_CFG" '^[[:space:]]*#keep_private_host = true'
assert_contains "$EVH_CFG" 'username = "janus"'
assert_contains "$EVH_CFG" 'password = "pa/ss&w|o\"rd\\x"'
[[ "$(file_mode "$JANUS_CFG")" == 644 ]] || fail "fresh janus.jcfg has mode $(file_mode "$JANUS_CFG")"

# CO-4495: changed credentials reach the live files on the next setup.
STUB_API_SECRET='rotated-secret' STUB_RABBITMQ_PASSWORD='rotated-password' "$CONFIGS"
assert_contains "$JANUS_CFG" 'api_secret = "rotated-secret"'
assert_contains "$EVH_CFG" 'password = "rotated-password"'

# Values the admin set by hand survive a re-render.
edit "$JANUS_CFG" 's|nat_1_1_mapping = .*|nat_1_1_mapping = "198.51.100.1,10.0.0.1"|'
edit "$JANUS_CFG" 's|#keep_private_host = true|keep_private_host = true|'
STUB_PUBLIC_IP='192.0.2.99' "$CONFIGS"
assert_contains "$JANUS_CFG" 'nat_1_1_mapping = "198.51.100.1,10.0.0.1"'
assert_matches "$JANUS_CFG" '^[[:space:]]*keep_private_host = true'

edit "$JANUS_CFG" 's|nat_1_1_mapping|#nat_1_1_mapping|'
"$CONFIGS"
assert_matches "$JANUS_CFG" '^[[:space:]]*#nat_1_1_mapping = "198.51.100.1,10.0.0.1"'

# yum never substituted the public IP, so the placeholder is still there.
cp "$JANUS_CFG.sample" "$JANUS_CFG"
"$CONFIGS"
assert_contains "$JANUS_CFG" 'nat_1_1_mapping = "203.0.113.7"'

# rpm moves a modified config it no longer ships to .rpmsave on upgrade.
edit "$JANUS_CFG" 's|nat_1_1_mapping = .*|nat_1_1_mapping = "198.51.100.1"|'
mv "$JANUS_CFG" "$JANUS_CFG.rpmsave"
"$CONFIGS"
assert_contains "$JANUS_CFG" 'nat_1_1_mapping = "198.51.100.1"'
rm "$JANUS_CFG.rpmsave"

# Without a public IP the mapping is left empty, and the next setup tries again.
rm "$JANUS_CFG"
STUB_PUBLIC_IP='' "$CONFIGS"
assert_contains "$JANUS_CFG" 'nat_1_1_mapping = ""'
"$CONFIGS"
assert_contains "$JANUS_CFG" 'nat_1_1_mapping = "203.0.113.7"'

# A missing api secret is generated and stored in Consul.
STUB_API_SECRET='' "$CONFIGS"
STORED_SECRET=$(grep ' carbonio-videoserver/api-secret ' "$STUB_CONSUL_PUTS" | awk '{print $NF}')
[[ -n "$STORED_SECRET" ]] || fail "api secret not stored in Consul"
assert_contains "$JANUS_CFG" "api_secret = \"$STORED_SECRET\""

# Missing broker credentials keep the event handler config already in place.
"$CONFIGS"
STUB_RABBITMQ_PASSWORD='' "$CONFIGS"
assert_contains "$EVH_CFG" 'password = "pa/ss&w|o\"rd\\x"'

# A mode the admin tightened on a file full of credentials is kept.
chmod 600 "$JANUS_CFG"
"$CONFIGS"
[[ "$(file_mode "$JANUS_CFG")" == 600 ]] || fail "re-render reset janus.jcfg to mode $(file_mode "$JANUS_CFG")"

# A missing template fails without touching the config in place.
mv "$JANUS_CFG.sample" "$TEST_DIR/template.away"
if "$CONFIGS" >/dev/null 2>&1; then
  fail "configs succeeded without the janus.jcfg template"
fi
assert_contains "$JANUS_CFG" 'api_secret = "api/secret+=="'
mv "$TEST_DIR/template.away" "$JANUS_CFG.sample"

if compgen -G "$JANUS_CONF_DIR/*.tmp.*" >/dev/null; then
  fail "temporary files left in $JANUS_CONF_DIR"
fi

echo "carbonio-videoserver-configs: all tests passed"
