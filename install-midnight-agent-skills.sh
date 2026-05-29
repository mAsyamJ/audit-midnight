#!/usr/bin/env bash
set -Eeuo pipefail

AGENTS=(claude-code cursor codex kiro-cli hermes-agent)

add_skill() {
  local pkg="$1"
  local skill="${2:-}"
  local cmd=(npx skills add "$pkg")
  if [[ -n "$skill" ]]; then
    cmd+=(--skill "$skill")
  fi
  for a in "${AGENTS[@]}"; do
    cmd+=(-a "$a")
  done
  cmd+=(-y)

  echo "[skills] ${cmd[*]}"
  if ! "${cmd[@]}"; then
    echo "[warn] full-agent install failed for pkg=$pkg skill=${skill:-<repo>}; retrying with core agents"
    local fallback=(npx skills add "$pkg")
    if [[ -n "$skill" ]]; then
      fallback+=(--skill "$skill")
    fi
    fallback+=(-a claude-code -a cursor -a codex -y)
    "${fallback[@]}" || echo "[warn] install failed: pkg=$pkg skill=${skill:-<repo>}"
  fi
}

echo "[1/6] Discovery skill"
add_skill "https://github.com/vercel-labs/skills" "find-skills"

echo "[2/6] Core EVM audit skills"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-master"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-general"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-defi-lending"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-precision-math"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-signatures"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-oracles"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-erc20"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-dos"
add_skill "https://github.com/austintgriffith/evm-audit-skills" "evm-audit-access-control"

echo "[3/6] Solidity audit suite + checklist-driven skill"
add_skill "https://github.com/gonzaloetjo/solidity-audit-skills" "*"
add_skill "https://github.com/farrellh1/smart-contract-auditor-skill"

echo "[4/6] Workflow skills"
add_skill "https://github.com/obra/superpowers" "writing-plans"
add_skill "https://github.com/obra/superpowers" "executing-plans"
add_skill "https://github.com/obra/superpowers" "systematic-debugging"
add_skill "https://github.com/obra/superpowers" "test-driven-development"
add_skill "https://github.com/obra/superpowers" "requesting-code-review"
add_skill "https://github.com/obra/superpowers" "receiving-code-review"
add_skill "https://github.com/obra/superpowers" "subagent-driven-development"
add_skill "https://github.com/obra/superpowers" "dispatching-parallel-agents"
add_skill "https://github.com/obra/superpowers" "using-git-worktrees"
add_skill "https://github.com/obra/superpowers" "verification-before-completion"

echo "[5/6] Optional testing/frontend skills"
add_skill "https://github.com/anthropics/skills" "webapp-testing"
add_skill "https://github.com/currents-dev/playwright-best-practices-skill" "playwright-best-practices"
add_skill "https://github.com/microsoft/playwright-cli" "playwright-cli"
add_skill "https://github.com/pbakaus/impeccable" "audit"

echo "[6/6] Installed skill lists"
npx skills list || true
for a in "${AGENTS[@]}"; do
  npx skills list -a "$a" || true
done

echo "[done] Midnight agent skills install routine completed."
