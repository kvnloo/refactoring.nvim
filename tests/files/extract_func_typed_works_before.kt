package org.example

class Calculator {
    fun total(prices: List<Int>, taxRate: Double): Double {
        val subtotal: Int = prices.sum()

        val tax: Double = subtotal * taxRate
        println("Subtotal: $subtotal")

        val result = subtotal + tax
        return result
    }
}
