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
# First filter the data like before
[
    .[] | select(
        ([.user] | inside($authors)) or
        (.url | contains("release-service-catalog")) or
        (.url | contains("release-service-utils")) or
        (.url | contains("/release-service/")) or
        (.url | contains("internal-services"))
    )
] as $filtered_prs |

# Enhance each PR with metadata
($filtered_prs | map(
    . + {
        "is_team_member": ([.user] | inside($authors)),
        "repository": (
            if (.url | contains("release-service-catalog")) then "release-service-catalog"
            elif (.url | contains("release-service-utils")) then "release-service-utils" 
            elif (.url | contains("/release-service/")) then "release-service"
            elif (.url | contains("internal-services")) then "internal-services"
            else (.url | capture(".*/(?<repo>[^/]+)/pull/.*").repo // "unknown")
            end
        )
    }
)) as $enhanced_prs |

# Group by repository
($enhanced_prs | group_by(.repository) | map({
    "repository": .[0].repository,
    "prs": .
}) | from_entries) as $by_repo |

# Calculate summary statistics
{
    "summary": {
        "generated_at": now | todateiso8601,
        "total_prs": ($enhanced_prs | length),
        "team_member_prs": ($enhanced_prs | map(select(.is_team_member)) | length),
        "external_prs": ($enhanced_prs | map(select(.is_team_member | not)) | length),
        "repositories": (
            $enhanced_prs | group_by(.repository) | map({
                "name": .[0].repository,
                "team_members": (map(select(.is_team_member)) | length),
                "external": (map(select(.is_team_member | not)) | length),
                "total": length
            }) | map({(.name): {
                "team_members": .team_members,
                "external": .external, 
                "total": .total
            }}) | add
        )
    },
    "by_repository": (
        $enhanced_prs | group_by(.repository) | map({
            (.[0].repository): .
        }) | add
    ),
    "all_pull_requests": $enhanced_prs
}'
