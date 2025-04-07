struct ITunesLinkButton: View {
    let trackUrl: URL

    var body: some View {
        Button(action: {
            UIApplication.shared.open(trackUrl, options: [:], completionHandler: nil)
        }) {
            Text("Jetzt bei iTunes")
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
        }
    }
}
