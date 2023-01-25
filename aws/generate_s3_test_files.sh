#!/bin/bash

# Generates random files with random data and upload to an S3 Bucket.
# Used just to test some S3 operations

[[ $# != 1 ]] && echo "Usage: $0 <bucket_name>" && exit 1

N_FILES=1000
BYTES=200000

S3_DEST_BUCKET=$1
S3_KEYS="test test1 test2 test3 test4 test5 test6 test7 test8 test9"

# Check first if the bucket exists
aws s3api head-bucket --bucket ${S3_DEST_BUCKET} || echo "Bucket ${S3_DEST_BUCKET} does not exist!" || exit 15

for d in ${S3_KEYS}; do
    mkdir -p ${d}
    for i in $(seq 1 ${N_FILES}); do
        filename=$(openssl rand -hex 12)
        cat /dev/urandom | head -c 200000 > ${d}/${filename}
    done
    aws s3 cp ./test s3://${S3_DEST_BUCKET}/${d} --recursive --quiet

    rm -fr ${d}
done
