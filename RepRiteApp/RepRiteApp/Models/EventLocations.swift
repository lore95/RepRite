import Foundation

struct Location: Identifiable, Decodable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let locationLat: Float
    let locationLon: Float

}
