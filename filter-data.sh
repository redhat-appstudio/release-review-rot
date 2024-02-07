#!/bin/bash
set -euo pipefail

authors='[
  "hbhati",
  "johnbieren",
  "mmalina",
  "theflockers",
  "davidmogar",
  "red-hat-konflux",
  "jinqi7"
]'

# Assumes data from stdin!
jq --argjson authors "${authors}" -r '[
    .[] | select(
        ([.user] | inside($authors)) or
        (.url | contains("/release/")) or
        (.title | test("RHTAPREL"; "i"))
    )
]'
