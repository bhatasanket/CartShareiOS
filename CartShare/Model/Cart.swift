//
//  Cart.swift
//  CartShare
//
//  Created by sanket bhat on 5/4/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import Foundation

struct Cart : Codable {
    var item : Item?
    
    enum CodingKeys: String, CodingKey {
        
        case item = "Item"
    }
    
    struct Item : Codable {
        var items : [Items]?
        let cartID : String?
        let familyID : String?
        
        enum CodingKeys: String, CodingKey {
            
            case items = "Items"
            case cartID = "cartID"
            case familyID = "familyID"
        }
        
        struct Items : Codable {
            let name : String?
            let addedBy : String?
            var completed : Bool?
            
            enum CodingKeys: String, CodingKey {
                
                case name = "name"
                case addedBy = "addedBy"
                case completed = "completed"
            }
            
        }
    }
}

struct CartResponse : Codable {
    let response : String?
    
    enum CodingKeys: String, CodingKey {
        
        case response = "response"
    }
    
}
