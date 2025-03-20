import SwiftUI

struct NavigationBarBackButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if let navController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
                            navController.popViewController(animated: true)
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white) // ✅ Weißes Chevron
                            Text("Zurück")
                                .foregroundColor(.white) // ✅ Weißer Button-Text
                        }
                    }
                }
            }
    }
}
