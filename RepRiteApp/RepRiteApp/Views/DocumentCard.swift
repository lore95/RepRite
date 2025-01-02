import SwiftUI

struct DocumentCard: View {
    let file: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(file.lastPathComponent)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)

            Text(formatDate(from: file))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 200, height: 100) // Adjust size as needed
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    private func formatDate(from file: URL) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let components = file.lastPathComponent.split(separator: "_")
        guard components.count > 1 else { return "Unknown Date" }
        return String(components[1]).replacingOccurrences(of: "-", with: "/")
    }
}