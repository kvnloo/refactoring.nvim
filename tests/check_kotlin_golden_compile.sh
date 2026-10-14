#!/bin/sh
# Compile each Kotlin golden output independently so symbol collisions do not mask errors.
set -eu

if ! command -v kotlinc >/dev/null 2>&1; then
    echo "kotlinc is required to check Kotlin golden output" >&2
    exit 2
fi

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

failed=0
# The original inferred-type extract_func_works_after.kt intentionally uses
# 'P' placeholders for types that Tree-sitter cannot determine; it is not
# compilable until those placeholders are filled in by the user.
# Compile only fully typed fixtures as an invariant for valid type capture.
for name in extract_func_typed_works_before extract_func_typed_works_after extract_var_works_after inline_var_comparison_operator_after; do
    input="$ROOT/tests/files/$name.kt"
    if kotlinc "$input" -d "$TMP/$name.jar" > "$TMP/$name.log" 2>&1; then
        printf 'PASS %s\n' "$name"
    else
        printf 'FAIL %s\n' "$name" >&2
        cat "$TMP/$name.log" >&2
        failed=1
    fi
done

exit "$failed"
