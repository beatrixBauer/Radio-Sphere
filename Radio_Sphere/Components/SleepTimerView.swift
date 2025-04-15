//
//  SleepTimerView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 17.04.25.
//

import SwiftUI

// MARK: Sleeptimer-Button in der PlayerView

struct SleepTimerView: View {
    @State private var selectedTime: Int?
    @State private var remainingTime: Int?
    @State private var timer: Timer?
    @StateObject private var manager = StationsManager.shared

    let sleepDurations = [5, 10, 15, 30, 60] // Auswahl in Minuten
    var iconSize: CGFloat = 30  // Standardgröße für das Timer-Icon

    var body: some View {
        Menu {
            ForEach(sleepDurations, id: \.self) { minutes in
                Button("\(minutes) Minuten") {
                    startTimer(minutes: minutes)
                }
            }
            Button("Timer stoppen", role: .destructive) {
                stopTimer()
            }
        } label: {
            HStack {
                Image(systemName: manager.isSleepTimerActive ? "timer.circle.fill" : "timer")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(manager.isSleepTimerActive ? .goldorange : .gray)
                    .shadow(radius: 4)
            }
        }
    }

    // Formatierung von Sekunden in mm:ss
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func startTimer(minutes: Int) {
        stopTimer()
        selectedTime = minutes
        remainingTime = minutes * 60
        manager.isSleepTimerActive = true
        manager.sleepTimerRemainingTime = remainingTime

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let timeLeft = remainingTime, timeLeft > 0 {
                remainingTime = timeLeft - 1
                manager.sleepTimerRemainingTime = remainingTime
            } else {
                stopTimer()
                manager.pausePlayback()
                print("Sleep-Timer abgelaufen: Musik gestoppt!")
            }
        }
        print("Sleep-Timer gesetzt auf \(minutes) Minuten")
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        selectedTime = nil
        remainingTime = nil
        manager.isSleepTimerActive = false
        manager.sleepTimerRemainingTime = nil
        print("Sleep-Timer gestoppt")
    }
}





