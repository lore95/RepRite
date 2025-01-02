//
//  DocumentCard.swift
//  RepRiteApp
//
//  Created by lorewnzo  on 2025-01-02.
//


import SwiftUI
struct DocumentCard: View {
    let file: URL

    var body: some View {
        VStack {
            Text(formatDate(from: file))
                .font(Font.custom("SpotLight-Regular", size: 20))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(formatTime(from: file))
                .font(Font.custom("SpotLight-Regular", size: 20))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding()
        .frame(width: 150, height: 100) // Adjust size for compact items
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    private func formatDate(from file: URL) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss" // Expected file date format

        let components = file.lastPathComponent.split(separator: "_")
        guard components.count > 2 else { return "Unknown Date" }

        // Extract the date part (e.g., "2025-01-01") and parse it
        let rawDate = String(components[2]) // Assuming "2025-01-01" is at index 2
        formatter.dateFormat = "yyyy-MM-dd" // Format of the raw date in the file name

        if let date = formatter.date(from: rawDate) {
            // Reformat the date to "dd-MM-yyyy"
            formatter.dateFormat = "dd-MM-yyyy"
            return formatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
    
    private func formatTime(from file: URL) -> String {
        let components = file.lastPathComponent.split(separator: "_")
        guard components.count > 3 else { return "Unknown Time" } // Ensure enough components exist

        let rawTime = String(components[3]) // Extract the time component (e.g., "12-30-00.json")

        // Remove everything after the '.' character
        if let timeWithoutExtension = rawTime.split(separator: ".").first {
            // Convert ArraySlice<Character> to String and replace '-' with ':'
            return String(timeWithoutExtension).replacingOccurrences(of: "-", with: ":")
        }

        // Fallback if split fails
        return rawTime.replacingOccurrences(of: "-", with: ":")
    }
}
