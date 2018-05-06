import Foundation

struct Family : Codable {
	let item : Item?

	enum CodingKeys: String, CodingKey {
		case item = "Item"
	}

    struct Item : Codable {
        let familyID : String?
        let carts : [String]?
        
        enum CodingKeys: String, CodingKey {
            
            case familyID = "familyID"
            case carts = "carts"
        }
        
    }

}


struct FamilyResponse : Codable {
    let response : String?
    
    enum CodingKeys: String, CodingKey {
        
        case response = "response"
    }
    
}
