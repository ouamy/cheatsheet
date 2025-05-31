#!/bin/bash

DEST_FOLDER="/home/opc/uploads"
SRC="$1"
DEST_NAME="${2:-$(basename "$SRC")}"

if [ -d "$SRC" ]; then
  # It's a directory, use -r to copy recursively
  scp -r -i /home/user0/pooptop.key "$SRC" opc@89.168.51.129:"$DEST_FOLDER/$DEST_NAME"
elif [ -f "$SRC" ]; then
  # It's a file
  scp -i /home/user0/pooptop.key "$SRC" opc@89.168.51.129:"$DEST_FOLDER/$DEST_NAME"
else
  echo "Error: '$SRC' is not a regular file or directory"
  exit 1
fi

