package com.finpilot.data.local

import app.cash.sqldelight.db.SqlDriver

expect class DatabaseDriverFactory {
    fun createDriver(): SqlDriver
}

object DatabaseFactory {
    fun createDatabase(driverFactory: DatabaseDriverFactory): FinPilotDatabase {
        val driver = driverFactory.createDriver()
        return FinPilotDatabase(driver)
    }
}
