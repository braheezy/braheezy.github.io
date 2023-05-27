#!/bin/bash
#
#   Pretty display word count of posts and drafts
#
set -euo pipefail

PINK="#f5c2e7"
BLUE="#74c7ec"
YELLOW="#f9e2af"
GREEN="#a6e3a1"

FOLDER_COLOR=$BLUE
COUNT_COLOR=$PINK
TEXT_COLOR=$YELLOW
TOTAL_COLOR=$GREEN

# Thanks ChatGPT...
for dir in _posts _drafts; do
  gum style --foreground $FOLDER_COLOR "$dir/"
  while read -r wordcount filename; do
    # extract filename without directory
    name="${filename##*/}"

    # Color parts of the sentence differently
    WORDCOUNT=$(gum style --foreground $COUNT_COLOR --bold --padding "0 0 0 2" "$wordcount")
    WORDS_IN=$(gum style --foreground $TEXT_COLOR "words in")
    NAME=$(gum style --foreground $COUNT_COLOR "$name")
    gum join --horizontal "$WORDCOUNT " "$WORDS_IN " "$NAME"
    # Find the files, count the words, and pipe results to loop(?)
  done < <(find "$dir" -name "*.md" -exec wc -w {} + | awk '{ print $1, $2 }' | sort -n)
done

# Also show the grant total count of words written
TOTAL_WORD_COUNT=$(wc -w _posts/*.md _drafts/*.md | grep total | awk '{ print $1 }' | gum style --bold)
gum style --foreground $TOTAL_COLOR \
          --border "thick" \
          --italic \
          --border-foreground $TOTAL_COLOR \
          --padding "0 1" \
          "Total words written: $TOTAL_WORD_COUNT"