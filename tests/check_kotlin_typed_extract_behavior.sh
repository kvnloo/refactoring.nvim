#!/bin/sh
# Independent downstream proof: compare observable behavior of the type-complete
# extract-function golden pair. This does not run Neovim's refactor generator.
set -eu

for tool in kotlinc java cmp; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "$tool is required for the Kotlin golden behavior check" >&2
        exit 2
    fi
done

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

cat > "$TMP/Runner.kt" <<'KOTLIN'
import org.example.Calculator

fun main() {
    val cases = listOf(
        emptyList<Int>() to 0.15,
        listOf(0) to 0.0,
        listOf(10, 20, 30) to 0.1,
        listOf(-10, 3, 2) to -0.25,
        listOf(1000000, -999999) to 0.075,
        listOf(Int.MAX_VALUE) to 0.0,
    )
    for ((index, case) in cases.withIndex()) {
        val (prices, rate) = case
        val actual = Calculator().total(prices, rate)
        val subtotal = prices.sum()
        val expected = subtotal.toDouble() + subtotal * rate
        check(actual.toBits() == expected.toBits()) {
            "case $index returned $actual, expected $expected"
        }
        println("case $index: ${actual.toBits()}")
    }
}
KOTLIN

for variant in before after; do
    src="$ROOT/tests/files/extract_func_typed_works_$variant.kt"
    kotlinc "$src" "$TMP/Runner.kt" -include-runtime -d "$TMP/$variant.jar"
    java -jar "$TMP/$variant.jar" > "$TMP/$variant.out"
done

if ! cmp -s "$TMP/before.out" "$TMP/after.out"; then
    echo "FAIL: extracted Kotlin golden changed return values or stdout" >&2
    diff -u "$TMP/before.out" "$TMP/after.out" >&2 || true
    exit 1
fi

echo "PASS: 6 typed Kotlin cases preserve return values and stdout before/after extraction"
