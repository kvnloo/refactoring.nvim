package org.example

class Calculator {
    private fun bar(subtotal: Int, taxRate: Double): Double {
        val tax: Double = subtotal * taxRate
        println("Subtotal: $subtotal")

        return tax
    }

    fun total(prices: List<Int>, taxRate: Double): Double {
        val subtotal: Int = prices.sum()

        val tax = bar(subtotal, taxRate)

        val result = subtotal + tax
        return result
    }
}
