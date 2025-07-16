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
jq --argjson authors "${authors}" -r '
# Filter the data like before
map(select(
    ([.user] | inside($authors)) or
    (.url | contains("release-service-catalog")) or
    (.url | contains("release-service-utils")) or
    (.url | contains("/release-service/")) or
    (.url | contains("internal-services"))
)) |
# Add metadata to each PR
map(. + {
    "is_team_member": ([.user] | inside($authors)),
    "repository": (
        if (.url | contains("release-service-catalog")) then "release-service-catalog"
        elif (.url | contains("release-service-utils")) then "release-service-utils" 
        elif (.url | contains("/release-service/")) then "release-service"
        elif (.url | contains("internal-services")) then "internal-services"
        else (.url | split("/") | .[-3] // "unknown")
        end
    )
}) |
# Create the final structure
{
    "generated_at": now | todateiso8601,
    "total_prs": length,
    "team_member_prs": map(select(.is_team_member)) | length,
    "external_prs": map(select(.is_team_member | not)) | length,
    "pull_requests": .
}'
