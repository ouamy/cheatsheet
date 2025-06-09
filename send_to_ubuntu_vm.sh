#!/bin/bash

DEST_FOLDER="/home/ubuntu/uploads"
SRC="$1"
DEST_NAME="${2:-$(basename "$SRC")}"

if [ -d "$SRC" ]; then
  scp -r -i /home/user0/localhost.key "$SRC" ubuntu@132.226.219.52:"$DEST_FOLDER/$DEST_NAME"
elif [ -f "$SRC" ]; then
  scp -i /home/user0/localhost.key "$SRC" ubuntu@132.226.219.52:"$DEST_FOLDER/$DEST_NAME"
else
  echo "Error: '$SRC' is not a regular file or directory"
  exit 1
fi

