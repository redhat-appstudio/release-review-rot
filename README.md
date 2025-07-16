# review-rot

A tool for generating review-rot dashboard for the Konflux Release team, published at: https://redhat-appstudio.github.io/release-review-rot/

## Overview

This repository tracks outstanding code reviews and pull requests across multiple Konflux repositories to ensure release-related work gets proper attention. The "review-rot" system helps prevent reviews from going stale and ensures nothing falls through the cracks during the release process.

## What it does

- **Monitors 9+ GitHub repositories** in the Konflux ecosystem
- **Tracks specific team members** and their review assignments
- **Filters for release-related content** (URLs with "/release/", titles with "RHTAPREL")
- **Generates JSON data** for the dashboard website
- **Publishes automatically** to GitHub Pages

## Setup

### Prerequisites

- [review-rot tool](https://github.com/reviewrot/reviewrot) installed
- GitHub Personal Access Token with repo access
- `jq` command-line JSON processor
- Bash shell

### Installation

1. **Install review-rot:**
   ```bash
   pip install reviewrot
   ```

2. **Set up GitHub token:**
   ```bash
   export GITHUB_TOKEN="your_github_personal_access_token"
   ```
   
   Or add to your shell profile (`~/.bashrc`, `~/.zshrc`):
   ```bash
   echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.zshrc
   ```

3. **Install jq** (if not already installed):
   ```bash
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt-get install jq
   
   # RHEL/CentOS
   sudo yum install jq
   ```

## Usage

### Generate Review Data

Run the complete pipeline to generate filtered review data:

```bash
# Generate raw review data and filter it
reviewrot -c config.yaml | ./filter-data.sh > filtered-reviews.json
```

### Manual Testing

Test the filtering logic with sample data:

```bash
# Test with existing data
cat sample-data.json | ./filter-data.sh
```

## Configuration

### config.yaml

The main configuration file defines:

- **Output format**: JSON for web consumption
- **GitHub repositories**: List of repos to monitor
- **Authentication**: Uses `GITHUB_TOKEN` environment variable

```yaml
arguments:
  format: json
git_services:
- host: github.com
  repos:
  - konflux-ci/release-service
  - konflux-ci/release-service-utils
  # ... more repos
  token: "${GITHUB_TOKEN}"
  type: github
```

### Adding/Removing Repositories

To monitor additional repositories, add them to the `repos` list in `config.yaml`:

```yaml
git_services:
- host: github.com
  repos:
  - konflux-ci/existing-repo
  - konflux-ci/new-repo-to-monitor  # Add new repo here
```

## Team Management

### Current Team Members

The following team members are tracked for review assignments:

- `hbhati`
- `johnbieren` 
- `mmalina`
- `theflockers`
- `davidmogar`
- `FilipNikolovski`
- `seanconroy2021`
- `Paul123111`
- `elenagerman`
- `red-hat-konflux`
- `jinqi7`

### Adding Team Members

To add a new team member to tracking:

1. **Edit `filter-data.sh`**
2. **Add the GitHub username** to the `authors` array:
   ```bash
   authors='[
     "hbhati",
     "johnbieren",
     "new-team-member",  # Add here
     # ... existing members
   ]'
   ```
3. **Test the change** locally
4. **Commit and push** - GitHub Actions will automatically update the dashboard

### Removing Team Members

To remove a team member:

1. **Remove their username** from the `authors` array in `filter-data.sh`
2. **Test and commit** the change

## Filtering Logic

The `filter-data.sh` script filters reviews based on three criteria:

1. **Team Member Reviews**: Reviews assigned to or created by tracked team members
2. **Release-related URLs**: Any review with "/release/" in the URL
3. **RHTAPREL Issues**: Reviews with "RHTAPREL" in the title (case-insensitive)

```bash
# The filter keeps reviews that match ANY of these conditions:
jq '[
    .[] | select(
        ([.user] | inside($authors)) or           # Team member involved
        (.url | contains("/release/")) or         # Release-related URL
        (.title | test("RHTAPREL"; "i"))         # RHTAPREL in title
    )
]'
```

## Monitored Repositories

| Repository | Purpose |
|------------|---------|
| `konflux-ci/release-service` | Main release service |
| `konflux-ci/release-service-utils` | Release utilities |
| `konflux-ci/internal-services` | Internal services |
| `konflux-ci/release-service-catalog` | Release catalog |
| `konflux-ci/e2e-tests` | End-to-end tests |
| `konflux-ci/build-definitions` | Build definitions |
| `konflux-ci/build-trusted-artifacts` | Trusted artifacts |
| `konflux-ci/docs` | Documentation |
| `redhat-appstudio/infra-deployments` | Infrastructure deployments |

## Local Development

### Testing Filter Changes

1. **Generate sample data:**
   ```bash
   reviewrot -c config.yaml > sample-output.json
   ```

2. **Test your filter:**
   ```bash
   cat sample-output.json | ./filter-data.sh | jq '.'
   ```

3. **Validate output:**
   ```bash
   # Check that output is valid JSON
   cat sample-output.json | ./filter-data.sh | jq 'length'
   ```

### Debugging

Enable verbose output to troubleshoot issues:

```bash
# Debug the shell script
bash -x ./filter-data.sh < sample-data.json

# Validate jq syntax
echo '[]' | jq --argjson authors '["test"]' '[.[] | select(([.user] | inside($authors)))]'
```

## Automation

- **GitHub Actions** automatically run on schedule and commits
- **Results published** to GitHub Pages at the URL above
- **No manual intervention** required for regular updates

## Troubleshooting

### Common Issues

1. **Missing GITHUB_TOKEN**:
   ```
   Error: GitHub API rate limit exceeded
   ```
   **Solution**: Set your GitHub token environment variable

2. **jq command not found**:
   ```
   ./filter-data.sh: line X: jq: command not found
   ```
   **Solution**: Install jq using your package manager

3. **Invalid JSON output**:
   **Solution**: Check that reviewrot is producing valid JSON with `reviewrot -c config.yaml | jq '.'`

### Getting Help

- Check the [review-rot documentation](https://github.com/reviewrot/reviewrot)
- Review GitHub Actions logs for automation issues
- Test changes locally before committing

## Contributing

1. **Fork** the repository
2. **Make changes** locally and test thoroughly
3. **Update documentation** if needed
4. **Submit pull request** with clear description

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
