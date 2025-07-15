#!/usr/bin/env bash

set -euo pipefail

echo "$PGPASSWORD" > ~/.pgpass
pg_dump --file backup.tar --format tar --no-password
rclone config touch
cat <<EOF > ~/.config/rclone/rclone.conf
[remote]
type = s3
provider = Cloudflare
access_key_id = $R2_ACCESS_KEY_ID
secret_access_key = $R2_SECRET_ACCESS_KEY
endpoint = $R2_ENDPOINT
acl = private
no_check_bucket = true
EOF

rclone copyto backup.tar remote:"$R2_BUCKET"/"$R2_PATH"