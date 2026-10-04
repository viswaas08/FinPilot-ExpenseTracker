pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
    }
}

rootProject.name = "FinPilot"

include(":core")
include(":domain")
include(":data")
include(":sync")
include(":auth")
include(":ai")
include(":sheets")
include(":notifications")
include(":shared-ui")
include(":androidApp")
include(":webApp")
