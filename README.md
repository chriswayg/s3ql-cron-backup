# S3QL encrypted cloud filesystem

[![Build Status](https://travis-ci.org/chriswayg/s3ql-cron-backup.svg?branch=master)](https://travis-ci.org/chriswayg/s3ql-cron-backup)
[![](https://images.microbadger.com/badges/image/chriswayg/s3ql-cron-backup.svg)](https://microbadger.com/images/chriswayg/s3ql-cron-backup)

[S3QL](https://bitbucket.org/nikratio/s3ql/) S3QL is a file system that stores all its data online using storage services like Google Storage, Amazon S3, or OpenStack. S3QL effectively provides a hard disk of dynamic, infinite capacity that can be accessed from any computer with internet access.

S3QL is a standard conforming, full featured UNIX file system that is conceptually indistinguishable from any local file system. Furthermore, S3QL has additional features like compression, encryption, data de-duplication, immutable trees and snapshotting which make it especially suitable for online backup and archival.

## How to Use

Create S3QL encrypted filesystem and mount it
```
docker run -d --init --name=s3ql-filesystem_1 --cap-add sys_admin --device=/dev/fuse \
-e S3QL_STORAGE_URL="gs://travis-temp-test-bucket" \
-e S3QL_BACKEND_LOGIN="GOOGNDASIXLIDR6A45APYFNC" \
-e S3QL_BACKEND_PASSWORD="Q0yOJofPrzg13Qa3R5cNnlu/WIUPO9BeCm6bFtia" \
-e S3QL_FS_PASSPHRASE="NVPBHCzWirXdHE9vDYAhcXTeXDnpBLoxDZqcpvfm" \
-e S3QL_CRONTAB="*/1 * * * * echo 'Hello'" \
s3ql-cron-backup
```

## Notes


## Author

- Christian Wagner
