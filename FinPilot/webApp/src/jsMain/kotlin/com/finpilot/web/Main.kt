package com.finpilot.web

import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.window.CanvasBasedWindow
import com.finpilot.ui.navigation.FinPilotApp

@OptIn(ExperimentalComposeUiApi::class)
fun main() {
    CanvasBasedWindow(canvasElementId = "finpilot_canvas", title = "FinPilot 2.0 — Personal Finance OS") {
        FinPilotApp()
    }
}
