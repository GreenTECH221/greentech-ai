#!/usr/bin/env bash
set -eu

# Tech Debt Report — Astro/Node variant (greentech-ai)
LINE_LIMIT=300
REPORT_FILE="tech-debt-report.md"

# 1. File counts
ASTRO_FILES=$(find src -name "*.astro" 2>/dev/null | wc -l | tr -d ' ')
TS_FILES=$(find src -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l | tr -d ' ')
JS_FILES=$(find src -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l | tr -d ' ')
TOTAL_SRC=$((ASTRO_FILES + TS_FILES + JS_FILES))
TOTAL_LINES=$(find src -name "*.astro" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')

# 2. Large files
LARGE_FILES=$(find src -name "*.astro" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" | xargs wc -l 2>/dev/null | awk "\$1 > ${LINE_LIMIT} && \$2 != \"total\"" | sort -rn)
LARGE_FILE_COUNT=$(echo "$LARGE_FILES" | grep -c . 2>/dev/null || echo "0")

# 3. Comment markers
TODO_COUNT=$(grep -rn 'TODO\|FIXME\|HACK\|XXX' src/ --include="*.astro" --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | wc -l | tr -d ' ')

# 4. Dependencies
if [ -f package.json ]; then
  DEP_COUNT=$(node -e "const p=require('./package.json'); console.log(Object.keys(p.dependencies||{}).length)" 2>/dev/null || echo "?")
  DEV_DEP_COUNT=$(node -e "const p=require('./package.json'); console.log(Object.keys(p.devDependencies||{}).length)" 2>/dev/null || echo "?")
else
  DEP_COUNT="?"
  DEV_DEP_COUNT="?"
fi

# 5. npm audit
if command -v npm &>/dev/null; then
  AUDIT_OUTPUT=$(npm audit --json 2>/dev/null || echo '{}')
  VULN_COUNT=$(echo "$AUDIT_OUTPUT" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{const a=JSON.parse(d);console.log(a.metadata?.vulnerabilities?.total||0)}catch{console.log('?')}})" 2>/dev/null || echo "?")
else
  VULN_COUNT="?"
fi

# Scoring
SCORE=100
SCORE=$((SCORE - TODO_COUNT))
LARGE_PENALTY=$((LARGE_FILE_COUNT > 10 ? 10 : LARGE_FILE_COUNT))
SCORE=$((SCORE - LARGE_PENALTY))
SCORE=$((SCORE < 0 ? 0 : SCORE))
if   [ "$SCORE" -ge 90 ]; then GRADE="A"
elif [ "$SCORE" -ge 75 ]; then GRADE="B"
elif [ "$SCORE" -ge 60 ]; then GRADE="C"
elif [ "$SCORE" -ge 40 ]; then GRADE="D"
else                            GRADE="F"
fi

{
cat <<EOF
# Tech Debt Report — greentech-ai

**Date:** $(date '+%Y-%m-%d')
**Grade:** ${GRADE} (${SCORE}/100)

## Summary

| Metric | Value |
|---|---|
| Astro files | ${ASTRO_FILES} |
| TS/TSX files | ${TS_FILES} |
| JS/JSX files | ${JS_FILES} |
| Total source files | ${TOTAL_SRC} |
| Total LOC | ${TOTAL_LINES} |
| Large files (>${LINE_LIMIT} lines) | ${LARGE_FILE_COUNT} |
| TODO/FIXME markers | ${TODO_COUNT} |
| Dependencies | ${DEP_COUNT} |
| Dev dependencies | ${DEV_DEP_COUNT} |
| npm vulnerabilities | ${VULN_COUNT} |

EOF

if [ "$LARGE_FILE_COUNT" -gt 0 ]; then
  echo "## Large Files (>${LINE_LIMIT} lines)"
  echo ""
  echo '```'
  echo "$LARGE_FILES" | head -10
  echo '```'
  echo ""
fi

if [ "$TODO_COUNT" -gt 0 ]; then
  echo "## TODO/FIXME Items"
  echo ""
  grep -rn 'TODO\|FIXME\|HACK\|XXX' src/ --include="*.astro" --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null | while IFS= read -r match; do
    file=$(echo "$match" | cut -d: -f1)
    line=$(echo "$match" | cut -d: -f2)
    text=$(echo "$match" | cut -d: -f3- | sed 's/^[[:space:]]*//')
    echo "- \`${file}:${line}\` — ${text}"
  done
  echo ""
fi

} | tee "$REPORT_FILE"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  cat "$REPORT_FILE" >> "$GITHUB_STEP_SUMMARY"
fi

echo ""
echo "--- Report written to ${REPORT_FILE} ---"
