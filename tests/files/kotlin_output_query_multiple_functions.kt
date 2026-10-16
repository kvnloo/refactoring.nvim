package org.example

class Counter(var value: Int)

// First top-level output declaration.
fun resetFirst(counter: Counter) {
    counter.value = 0
}

// Second top-level output declaration: must not disappear from the query.
fun resetSecond(counter: Counter) {
    counter.value = 1
}

class Actions {
    // First class-body output declaration.
    fun clear(counter: Counter) {
        counter.value = 0
    }

    // Second class-body output declaration: must not disappear from the query.
    fun increment(counter: Counter) {
        counter.value += 1
    }
}
