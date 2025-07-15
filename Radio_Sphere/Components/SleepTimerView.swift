//
//  SleepTimerView.swift
//  Radio_Sphere
//


import SwiftUI

struct SleepTimerView: View {
    @StateObject private var manager = StationsManager.shared
    let sleepDurations = [5, 10, 15, 20, 30, 60]  // Auswahl in Minuten
    var iconSize: CGFloat = 30                // Icon‑Größe

    var body: some View {
        Menu {
            // Buttons zum Starten des Timers
            ForEach(sleepDurations, id: \.self) { minutes in
                Button("\(minutes) Minuten") {
                    manager.startSleepTimer(minutes: minutes)
                }
            }
            // Button zum Stoppen
            Button("Timer stoppen", role: .destructive) {
                manager.stopSleepTimer()
            }
        } label: {
            // Icon wechselt je nach Timer‑State
            Image(systemName: manager.isSleepTimerActive
                  ? "timer.circle.fill"
                  : "timer")
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(manager.isSleepTimerActive ? .goldorange : .gray)
                .shadow(radius: 4)
        }
    }
}




