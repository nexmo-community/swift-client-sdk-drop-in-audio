import Foundation

struct RoomResponse: Codable {
    let id: String
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}

struct CreateRoom: Codable {
    struct Body: Codable {
        let displayName: String
        
        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
        }
    }
    
    struct Response: Codable {
        let id: String
    }
}

struct Auth: Codable {
    struct Body: Codable {
        let name: String
    }
    
    struct Response: Codable {
        let name: String
        let jwt: String
    }
}
