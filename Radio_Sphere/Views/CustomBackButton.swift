import SwiftUI

struct CustomBackButton: View {
    let backgroundColor: Color
    let foregroundColor: Color
    let onBack: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: {
            if let onBack = onBack {
                print("onBack action triggered")  // Debug-Ausgabe
                onBack()  // Aufruf der onBack-Funktion, wenn vorhanden
            } else {
                print("onBack action is nil")  // Debug-Ausgabe, falls die Funktion nil ist
            }
            dismiss()  // Schließt den View nach der Ausführung der onBack-Funktion
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(foregroundColor)
            Text("Back")
                .font(.custom("Quicksand-SemiBold", size: 16))
                .foregroundColor(foregroundColor)
        }
    }
}