//
//  RegisterViewController.swift
//  CartShare
//
//  Created by sanket bhat on 5/4/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    var user:User? = nil
    let awsClient = AWSClient()
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRePassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func txtUsernameValid(_ sender: UITextField) {
        guard let username = txtUserName.text else {
            return
        }
        if txtUserName.text == "" {
            txtUserName.becomeFirstResponder()
            return
        }
        txtPassword.isEnabled = false
        txtRePassword.isEnabled = false
        awsClient.isUserValid(userID: username.lowercased(), password: ""){(response) in
            if response.response == "successful" || response.response == "passwordFail" {
                OperationQueue.main.addOperation {
                    let alert = UIAlertController(title: "User name already exists", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.txtUserName.text = ""
                    self.txtPassword.text = ""
                    self.txtUserName.becomeFirstResponder()
                    return
                }
            }else{
                OperationQueue.main.addOperation {
                    self.txtPassword.isEnabled = true
                    self.txtRePassword.isEnabled = true
                    self.txtPassword.becomeFirstResponder()
                    
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //
    
    @IBAction func bttnRegister(_ sender: UIButton) {
        guard txtFirstName.text != "", let firstName = txtFirstName.text,
            txtLastName.text != "", let lastName = txtLastName.text,
            txtUserName.text != "", let userName = txtUserName.text?.lowercased(),
            txtPassword.text != "", let password = txtPassword.text,
            txtRePassword.text != "", let rePassword = txtRePassword.text
            else {
                let alert = UIAlertController(title: "All fields are mandatory", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
        }
        guard password == rePassword else {
            let alert = UIAlertController(title: "passwords do not match", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.txtPassword.text = ""
            self.txtRePassword.text = ""
            return
        }
        user = User(item: User.Item(password: password, family: [], firstName: firstName, lastName: lastName, userID: userName))
        awsClient.saveUser(user: user!){ (response) in
            if response.response == "successful"{
                print("success")
                self.performSegue(withIdentifier: "registerToFamily", sender: self)
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

extension RegisterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.txtFirstName:
            txtLastName.becomeFirstResponder()
        case self.txtLastName:
            txtUserName.becomeFirstResponder()
            //        case self.txtUserName:
        //            txtPassword.becomeFirstResponder()
        case self.txtPassword:
            txtRePassword.becomeFirstResponder()
        case self.txtRePassword:
            txtRePassword.resignFirstResponder()
        default:
            return textField.resignFirstResponder()
        }
        return true
    }
}

