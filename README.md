[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/aujTA1?referralCode=xsbY2R)

# Backup Postgres to Cloudflare R2

This Docker app runs a single time, dumping a Postgres database with [pg_dump] and using [rclone] to push that data to [Cloudflare R2](https://developers.cloudflare.com/r2/).

You schedule the container to run at whatever interval you want backups to happen using Railway's built-in cron feature 
rather than continuously running the app (like the official backup script).

## Setup

The container needs the environment variables related to Postgres:

- `PGHOST`: The host to connect to, for example `localhost` or `127.0.0.1`.
- `PGDATABASE`: The name of the database to dump.
- `PGPORT`: The port to connect to, defaults to `5432`
- `PGUSER`: Username for Postgres
- `PGPASSWORD`: Password for Postgres

And these variables related to Cloudflare R2:

- `R2_ACCESS_KEY_ID` and `R2_SECRET_ACCESS_KEY`: An [S3-compatible access key](https://developers.cloudflare.com/r2/api/s3/tokens/)
- `R2_ENDPOINT`: The S3 API URL for your R2 account
- `R2_BUCKET`: The name of the bucket to upload to
- `R2_PATH`: A path within the R2 bucket to upload the `.tar` to, defaults to `"postgres-backup.tar"`

### Railway-specific guide

> [!TIP]
> You can also [deploy Postgres with these backups enabled](https://railway.app/template/xNTYS8?referralCode=xsbY2R) if you don't have a database yet.

If you're running this container in Railway, you can use shared variables for all the Postgres variables (replace `Postgres` in each expression with the name of your database service):

- `PGHOST`: `${{Postgres.PGHOST}}`
- `PGDATABASE`: `${{Postgres.PGDATABASE}}`
- `PGPORT`: `${{Postgres.PGPORT}}`
- `PGUSER`: `${{Postgres.PGUSER}}`
- `PGPASSWORD`: `${{Postgres.PGPASSWORD}}`

Then, in settings, set restart to never and input a cron schedule to backup as often as you'd like.

## Restoring from a backup

1. Install [pg_restore] and [rclone]
2. Create the same [rclone config file] that this container does
3. Run `rclone copy remote:$R2_BUCKET/$R2_PATH ./$LOCAL_FILE_TO_CREATE`
4. Run `pg_restore --host $PGHOST -W --username $PGUSER -d $PGDATABASE $LOCAL_FILE_TO_CREATE`
5. Enter password manually

## FAQ

### Using something other than Cloudflare R2

You can fork this repo and modify the [rclone config file] to work for any storage destination [that rclone supports](https://rclone.org/#providers) (which is pretty much everything).

### Using a different Postgres version

Update `postgresql17-client` in `Dockerfile` to whichever version of Postgres you'd like.

[pg_dump]: https://www.postgresql.org/docs/current/app-pgdump.html
[pg_restore]: https://www.postgresql.org/docs/current/app-pgrestore.html
[rclone]: https://rclone.org
[rclone config file]: https://github.com/dbanty/rclone-postgres-backup/tree/entrypoint.sh#L7-L16
