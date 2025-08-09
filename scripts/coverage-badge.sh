#!/usr/bin/env bash
set -euo pipefail

RESULT_BUNDLE="${1:-build/TestResults.xcresult}"

if [[ ! -d "$RESULT_BUNDLE" ]]; then
  echo "Result bundle not found at: $RESULT_BUNDLE" >&2
  echo "Run 'make coverage' first or pass a path to an .xcresult." >&2
  exit 1
fi

# Extract the GitHubApp.app coverage percentage as a number (e.g., 82.83)
LINE=$(xcrun xccov view --report --only-targets "$RESULT_BUNDLE" | grep 'GitHubApp.app' || true)
PCT=$(echo "$LINE" | sed -E 's/.* ([0-9]+\.?[0-9]*)% .*/\1/')

if [[ -z "$PCT" ]]; then
  echo "Could not parse coverage percentage for GitHubApp.app" >&2
  exit 1
fi

# Round to nearest integer for the badge display
PCT_INT=$(printf '%.0f' "$PCT")

# Choose a color based on thresholds
COLOR="red"
if   (( PCT_INT >= 90 )); then COLOR="#4c1";   # bright green
elif (( PCT_INT >= 80 )); then COLOR="#97CA00"; # green
elif (( PCT_INT >= 70 )); then COLOR="#a4a61d"; # yellow-green
elif (( PCT_INT >= 60 )); then COLOR="#dfb317"; # yellow
elif (( PCT_INT >= 50 )); then COLOR="#fe7d37"; # orange
else                           COLOR="#e05d44"; # red
fi

mkdir -p badges
BADGE_PATH="badges/coverage.svg"

# Basic SVG badge (no external deps)
cat > "$BADGE_PATH" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="120" height="20" role="img" aria-label="coverage: ${PCT_INT}%">
  <linearGradient id="b" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <mask id="a">
    <rect width="120" height="20" rx="3" fill="#fff"/>
  </mask>
  <g mask="url(#a)">
    <rect width="60" height="20" fill="#555"/>
    <rect x="60" width="60" height="20" fill="${COLOR}"/>
    <rect width="120" height="20" fill="url(#b)"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
    <text x="30" y="15" fill="#010101" fill-opacity=".3">coverage</text>
    <text x="30" y="14">coverage</text>
    <text x="90" y="15" fill="#010101" fill-opacity=".3">${PCT_INT}%</text>
    <text x="90" y="14">${PCT_INT}%</text>
  </g>
</svg>
SVG

echo "Generated $BADGE_PATH for GitHubApp.app coverage: ${PCT}%"
