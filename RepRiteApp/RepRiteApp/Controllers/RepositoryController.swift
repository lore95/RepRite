//
//  RepositoryController.swift
//  RepRiteApp
//
//  Created by lorewnzo  on 2025-01-02.
//


import Foundation

class RepositoryController: ObservableObject {
    @Published var files: [URL] = [] // List of available JSON files
    @Published var locations: [Location] = []

    private let userIdentifier: String

    init(userIdentifier: String) {
        self.userIdentifier = userIdentifier
        fetchJSONFiles()
    }

    /// Fetch all JSON files belonging to the current user
    func fetchJSONFiles() {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // Filter files by the user's identifier in the filename
            files = fileURLs.filter {
                $0.pathExtension == "json" && $0.lastPathComponent.contains(userIdentifier)
            }
        } catch {
            print("Error fetching files: \(error.localizedDescription)")
            files = []
        }
    }

    /// Save an exercise session with the user's identifier in the filename
    func saveSession(_ session: ExerciseSession, forUser user: String) {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()

        // Use the current date and time as the filename
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let filename = "Session_\(user)_\(formatter.string(from: session.date)).json"
        let fileURL = documentsURL.appendingPathComponent(filename)

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(session)
            try jsonData.write(to: fileURL)
            print("Session saved to \(fileURL).")
            fetchJSONFiles() // Refresh file list
        } catch {
            print("Error saving session: \(error.localizedDescription)")
        }
    }

    /// Get Documents Directory Path
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func loadLocationsFromLocalStorage() {
            guard let url = Bundle.main.url(forResource: "events", withExtension: "json") else {
                print("JSON file not found")
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decodedLocations = try JSONDecoder().decode([Location].self, from: data)
                self.locations = decodedLocations
            } catch {
                print("Error loading locations from local storage: \(error)")
            }
        }
}
