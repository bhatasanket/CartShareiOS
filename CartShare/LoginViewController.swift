//
//  LoginViewController.swift
//  CartShare
//
//  Created by sanket bhat on 5/3/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let awsClient = AWSClient()
    
    var user:User? = nil
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func getInAction(_ sender: UIButton) {
        
        guard let username = txtUserName.text, let password = txtPassword.text else {
            return
        }
        awsClient.isUserValid(userID: username, password: password){(response) in
            print(response)
            if response.response == "successful"{
                
                self.awsClient.getUserDetails(userID: username, password: password){(response) in
                    switch response{
                    case let .success(detail):
                        self.user = detail
                        self.performSegue(withIdentifier: "loginTofamily", sender: self)
                    case let .failure(error):
                        print(error)
                        let alert = UIAlertController(title: "failed to fetch family", message: "try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.txtPassword.text = ""
                        self.txtPassword.becomeFirstResponder()
                        return
                    }
                }
                

                
            }else{
                
            }
        }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let controller = segue.destination as! FamilyViewController
        controller.user = user!
    }
    
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.txtUserName:
            txtPassword.becomeFirstResponder()
        default:
            return textField.resignFirstResponder()
        }
        return true
    }
}


