//
//  SleepTimerView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 17.03.25.
//


import SwiftUI

struct SleepTimerView: View {
    @State private var selectedTime: Int? = nil
    @State private var remainingTime: Int? = nil
    @State private var timer: Timer? = nil
    @StateObject private var manager = StationsManager.shared

    let sleepDurations = [5, 10, 15, 30, 60] // Minutenauswahl

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
            Image(systemName: "timer") // Sleep-Timer Icon
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(selectedTime != nil ? .goldorange : .gray)
                .shadow(radius: 4)
        }
        .onDisappear {
            stopTimer() // Falls die View verschwindet, Timer beenden
        }
    }

    /// Startet den Timer
    private func startTimer(minutes: Int) {
        stopTimer() // Falls bereits ein Timer läuft, stoppen
        selectedTime = minutes
        remainingTime = minutes * 60

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let timeLeft = remainingTime, timeLeft > 0 {
                remainingTime = timeLeft - 1
            } else {
                stopTimer()
                manager.pausePlayback() // Musik stoppen
                print("Sleep-Timer abgelaufen: Musik gestoppt!")
            }
        }

        print("Sleep-Timer gesetzt auf \(minutes) Minuten")
    }

    /// Stoppt den Timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        selectedTime = nil
        remainingTime = nil
        print("Sleep-Timer gestoppt")
    }
}

#Preview {
    SleepTimerView()
}
