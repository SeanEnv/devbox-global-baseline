#!/usr/bin/env bash
set -euo pipefail

file="${1:-}"
[ -n "$file" ] || exit 0

mimetype="$(file --mime-type -Lb -- "$file" 2>/dev/null || echo application/octet-stream)"

case "$mimetype" in
  text/*|*/json|*/xml)
    if command -v bat >/dev/null 2>&1; then
      bat --style=plain --color=always --paging=never -- "$file"
    else
      sed -n '1,500p' -- "$file"
    fi
    ;;
  image/*)
    if command -v viu >/dev/null 2>&1; then
      viu -w "$(tput cols)" -h "$(tput lines)" -- "$file"
    else
      echo "Image: $(basename "$file")"
      file --brief -- "$file"
    fi
    ;;
  video/*|audio/*)
    if command -v exiftool >/dev/null 2>&1; then
      exiftool -s -- "$file" | sed -n '1,200p'
    else
      echo "Media: $(basename "$file")"
      file --brief -- "$file"
    fi
    ;;
  application/pdf)
    if command -v pdftotext >/dev/null 2>&1; then
      pdftotext -layout -- "$file" - | sed -n '1,500p'
    else
      echo "PDF: install poppler for text preview"
    fi
    ;;
  *)
    echo "No preview for $mimetype"
    ;;
esac
