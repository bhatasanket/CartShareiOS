//
//  AWSClient.swift
//  CartShare
//
//  Created by sanket bhat on 5/4/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import Foundation

enum UserResult {
    case success(User)
    case failure(Error)
}

enum FamilyResult {
    case success(Family)
    case failure(Error)
}

enum CartResult {
    case success(Cart)
    case failure(Error)
}

class AWSClient {
    let awsBaseURL = "1jfksbuada.execute-api.us-west-2.amazonaws.com"
    
    func isUserValid(userID: String, password: String, completion: @escaping (LoginResponse) -> Void) {
        
        let post = UserLogin(Item: UserLogin.Item(userID: userID, password: password))
        
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/user/login"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(post)
            
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        }catch let err {
            print(err)
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) {
            (data, _, error) -> Void in
            if error != nil {
                print(error!)
                completion(LoginResponse(response: "fail"))
            } else {
                let jsonDecoder = JSONDecoder()
                do {
                    let responseModel = try jsonDecoder.decode(LoginResponse.self, from: data!)
//                if let returnData = String(data: data!, encoding: .utf8) {
                    completion(responseModel)
                } catch {
                    completion(LoginResponse(response: "fail"))
                }
            }
            
        }.resume()
    }
    
    
    
    func saveUser(user: User, completion: @escaping (LoginResponse) -> Void) {
        
        let post = user
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/user"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(post)
            
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        }catch let err {
            print(err)
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) {
            (data, _, error) -> Void in
            if error != nil {
                print(error!)
                completion(LoginResponse(response: "fail"))
            } else {
                let jsonDecoder = JSONDecoder()
                do {
                    print(String(data: data!, encoding: .utf8))
                    let responseModel = try jsonDecoder.decode(LoginResponse.self, from: data!)
                    //                if let returnData = String(data: data!, encoding: .utf8) {
                    completion(responseModel)
                } catch {
                    completion(LoginResponse(response: "fail"))
                }
            }

            }.resume()
    }
    
    func getUserDetails(userID: String, password: String, completion: @escaping (UserResult) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/user"
        urlComponents.queryItems = [URLQueryItem(name: "userID", value: userID),URLQueryItem(name: "password", value: password)]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        //        let url = URL(string: "https://"+awsBaseURL+"/prod/user?userID=\(userID)&password=\(password)")
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) {
            (data, response, error) -> Void in
            print(error?.localizedDescription)

            let result = self.processUserRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    enum UserResult {
        case success(User)
        case failure(Error)
    }
    private func processUserRequest(data: Data?, error: Error?) -> UserResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return self.getUserResult(fromJSON: jsonData)
    }
    public func getUserResult(fromJSON data: Data) -> UserResult {
        do {
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
                        print(String(data:data, encoding: .utf8)!)
            let response = try decoder.decode(User.self, from: data)
            return .success(response)
        } catch let jsonDecoderError {
            return .failure(jsonDecoderError)
        }
    }
    
    
    
    func getUserDetailsforInvite(userID: String, completion: @escaping (UserResult) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/user/invite"
        urlComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        //        let url = URL(string: "https://"+awsBaseURL+"/prod/user?userID=\(userID)&password=\(password)")
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) {
            (data, response, error) -> Void in
            print(error?.localizedDescription)
            
            let result = self.processUserRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    
    
    enum FamilyResult{
        case success(Family)
        case failure(Error)
    }
    private func processFamilyRequest(data: Data?, error: Error?) -> FamilyResult{
        guard let jsonData = data else {
            return .failure(error!)
        }
        return self.getFamilyResult(fromJSON: jsonData)
    }
    
    public func getFamilyResult(fromJSON data: Data) -> FamilyResult {
        do {
            let decoder = JSONDecoder()
            //            decoder.keyDecodingStrategy = .convertFromSnakeCase
            print(String(data:data, encoding: .utf8)!)
            let response = try decoder.decode(Family.self, from: data)
            return .success(response)
        } catch let jsonDecoderError {
            return .failure(jsonDecoderError)
        }
    }
    
    func getFamilyDetails(familyID: String,completion: @escaping (FamilyResult)-> Void){
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/family"
        urlComponents.queryItems = [URLQueryItem(name: "familyID", value: familyID)]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        
        
//        let url = URL(string: "https://"+awsBaseURL+"/prod/family?familyID=\(familyID)")
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) {
            (data, response, error) -> Void in
            print(error?.localizedDescription)
            
            let result = self.processFamilyRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }

    
    func saveFamily(family : Family, completion: @escaping (FamilyResponse) -> Void) {
        
        let post = family
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/family"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(post)
            
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        }catch let err {
            print(err)
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) {
            (data, _, error) -> Void in
            if error != nil {
                print(error!)
                completion(FamilyResponse(response: "fail"))
            } else {
                let jsonDecoder = JSONDecoder()
                do {
                    let responseModel = try jsonDecoder.decode(FamilyResponse.self, from: data!)
                    //                if let returnData = String(data: data!, encoding: .utf8) {
                    completion(responseModel)
                } catch {
                    completion(FamilyResponse(response: "fail"))
                }
            }
            
            }.resume()
    }
    
    
    
    
    enum CartResult{
        case success(Cart)
        case failure(Error)
    }
    private func processCartRequest(data: Data?, error: Error?) -> CartResult{
        guard let jsonData = data else {
            return .failure(error!)
        }
        return self.getCartResult(fromJSON: jsonData)
    }
    
    public func getCartResult(fromJSON data: Data) -> CartResult {
        do {
            let decoder = JSONDecoder()
            //            decoder.keyDecodingStrategy = .convertFromSnakeCase
            print(String(data:data, encoding: .utf8)!)
            let response = try decoder.decode(Cart.self, from: data)
            return .success(response)
        } catch let jsonDecoderError {
            return .failure(jsonDecoderError)
        }
    }
    
    func getCartDetails(cartID:String, familyID: String,completion: @escaping (CartResult)-> Void){
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/cart"
        urlComponents.queryItems = [URLQueryItem(name: "cartID", value: cartID),URLQueryItem(name: "familyID", value: familyID)]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
//        let url = URL(string: "https://"+awsBaseURL+"/prod/cart?cartID=\(cartID)&familyID=\(familyID)")
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) {
            (data, response, error) -> Void in
            print(error?.localizedDescription)
            
            let result = self.processCartRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }

    
    func saveCart(cart : Cart, completion: @escaping (CartResponse) -> Void) {
        
        let post = cart
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/cart"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(post)
            
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        }catch let err {
            print(err)
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) {
            (data, _, error) -> Void in
            if error != nil {
                print(error!)
                completion(CartResponse(response: "fail"))
            } else {
                let jsonDecoder = JSONDecoder()
                do {
                    let responseModel = try jsonDecoder.decode(CartResponse.self, from: data!)
                    //                if let returnData = String(data: data!, encoding: .utf8) {
                    completion(responseModel)
                } catch {
                    completion(CartResponse(response: "fail"))
                }
            }
            
        }.resume()
    }
    
    
    func deleteCart(cartID:String, familyID: String,completion: @escaping (CartResponse)-> Void){
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = awsBaseURL
        urlComponents.path = "/prod/cart"
        urlComponents.queryItems = [URLQueryItem(name: "cartID", value: cartID),URLQueryItem(name: "familyID", value: familyID)]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) {
            (data, _, error) -> Void in
            if error != nil {
                print(error!)
                completion(CartResponse(response: "fail"))
            } else {
                let jsonDecoder = JSONDecoder()
                do {
                    let responseModel = try jsonDecoder.decode(CartResponse.self, from: data!)
                    //                if let returnData = String(data: data!, encoding: .utf8) {
                    completion(responseModel)
                } catch {
                    completion(CartResponse(response: "fail"))
                }
            }
        }.resume()
    }
}

