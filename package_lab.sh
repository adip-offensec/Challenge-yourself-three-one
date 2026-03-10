#!/bin/bash
# Package the lab for distribution
LAB_NAME="ad-attack-lab"
VERSION="1.0"
OUTPUT="${LAB_NAME}-${VERSION}.zip"

echo "Packaging lab into $OUTPUT ..."
zip -r "$OUTPUT" . -x "*.git*" "*.vagrant*" "*.box*" "package_lab.sh"
echo "Done. Package saved as $OUTPUT"
