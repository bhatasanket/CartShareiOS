//
//  User.swift
//  CartShare
//
//  Created by sanket bhat on 5/4/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import Foundation
struct User : Codable {
    var Item : Item?
    
    enum CodingKeys: String, CodingKey {
        
        case Item = "Item"
    }
    
    struct Item : Codable {
        let password : String?
        var family : [String]?
        let firstName : String?
        let lastName : String?
        let userID : String?
        var invitations : [String]?
        
        enum CodingKeys: String, CodingKey {
            
            case password = "password"
            case family = "family"
            case firstName = "firstName"
            case lastName = "lastName"
            case userID = "userID"
            case invitations = "invitations"
        }
        
        
    }
}

struct UserLogin: Codable {
    let Item : Item?
    
    enum CodingKeys: String, CodingKey {
        
        case Item
    }
    
    struct Item : Codable {
        let userID : String?
        let password : String?
        
        enum CodingKeys: String, CodingKey {
            
            case userID = "userID"
            case password = "password"
        }
        
    }
}
struct LoginResponse : Codable {
    let response : String?
    
    enum CodingKeys: String, CodingKey {
        
        case response = "response"
    }
    
}
