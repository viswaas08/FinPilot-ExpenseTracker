package com.finpilot.data.local

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver

actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        val driver: SqlDriver = JdbcSqliteDriver("jdbc:sqlite:finpilot_v2.db")
        try {
            FinPilotDatabase.Schema.create(driver)
        } catch (_: Exception) {
            // Already created
        }
        return driver
    }
}
