#!/bin/bash
set -euo pipefail

echo "MY SCRIPT IS RUNNING"

SEARCH_PATTERN=$1
OUTPUT=$2

echo "OUTPUT is: $OUTPUT"

curl -o mobydick.txt https://gist.githubusercontent.com/StevenClontz/4445774/raw/1722a289b665d940495645a5eaaad4da8e3ad4c7/mobydick.txt

OCCURRENCES=$(grep -o "$SEARCH_PATTERN" mobydick.txt | wc -l)

echo "The pattern '$SEARCH_PATTERN' appears $OCCURRENCES times in the file." > "$OUTPUT"