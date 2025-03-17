struct ActionButton: View {
    let systemName: String
    let action: () -> Void
    let buttonSize: CGFloat

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: {
            isPressed = true  // Button auf Goldorange setzen
            action()  // Hauptaktion ausführen

            // Nach kurzer Zeit wieder auf Grau setzen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: buttonSize, height: buttonSize)
                .foregroundColor(isPressed ? Color("goldOrange") : .gray) // 🔥 Dynamische Farbe
                .shadow(radius: 4)
        }
    }
}
