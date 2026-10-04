package com.finpilot.core.logging

object AppLogger {
    var isDebugEnabled: Boolean = true

    fun d(tag: String, message: String) {
        if (isDebugEnabled) {
            println("DEBUG: [$tag] $message")
        }
    }

    fun i(tag: String, message: String) {
        println("INFO:  [$tag] $message")
    }

    fun w(tag: String, message: String, throwable: Throwable? = null) {
        println("WARN:  [$tag] $message")
        throwable?.let { println("       ${it.stackTraceToString()}") }
    }

    fun e(tag: String, message: String, throwable: Throwable? = null) {
        println("ERROR: [$tag] $message")
        throwable?.let { println("       ${it.stackTraceToString()}") }
    }
}
