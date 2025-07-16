#!/bin/bash
set -euo pipefail

authors='[
  "hbhati",
  "johnbieren",
  "mmalina",
  "theflockers",
  "davidmogar",
  "FilipNikolovski",
  "seanconroy2021",
  "Paul123111",
  "elenagerman",
  "red-hat-konflux",
  "jinqi7"
]'

# Assumes data from stdin!
jq --argjson authors "${authors}" -r '[
    .[] | select(
        ([.user] | inside($authors)) or
        (.url | contains("release-service-catalog")) or
        (.url | contains("release-service-utils")) or
        (.url | contains("/release-service/")) or
        (.url | contains("internal-services"))
    )
]'
