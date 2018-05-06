//
//  User.swift
//  CartShare
//
//  Created by sanket bhat on 5/4/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import Foundation
struct User : Codable {
    var item : Item?
    
    enum CodingKeys: String, CodingKey {
        
        case item = "Item"
    }
    
    struct Item : Codable {
        let password : String?
        var family : [String]?
        let firstName : String?
        let lastName : String?
        let userID : String?
        
        enum CodingKeys: String, CodingKey {
            
            case password = "password"
            case family = "family"
            case firstName = "firstName"
            case lastName = "lastName"
            case userID = "userID"
        }
        
        
    }
}

struct UserLogin: Codable {
    let item : Item?
    
    enum CodingKeys: String, CodingKey {
        
        case item
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
