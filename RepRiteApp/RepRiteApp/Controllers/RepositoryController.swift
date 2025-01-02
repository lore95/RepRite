import Foundation

class RepositoryController: ObservableObject {
    @Published var files: [URL] = [] // List of available JSON files
    @Published var selectedFile: URL? = nil // Currently selected file

    init() {
        fetchJSONFiles()
    }

    /// Fetch all JSON files from the app's Documents Directory
    func fetchJSONFiles() {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            files = fileURLs.filter { $0.pathExtension == "json" } // Filter JSON files
        } catch {
            print("Error fetching files: \(error.localizedDescription)")
            files = []
        }
    }

    /// Save an exercise session to a file
    func saveSession(_ session: ExerciseSession) {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()

        // Use the current date and time as the filename
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let filename = "Session_\(formatter.string(from: session.date)).json"
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
}