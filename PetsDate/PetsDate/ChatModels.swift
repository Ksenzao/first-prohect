import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    var id: String = UUID().uuidString
    var senderId: String
    var text: String
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id, senderId, text, timestamp
    }
}
