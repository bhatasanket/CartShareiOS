//
//  FamilyViewController.swift
//  CartShare
//
//  Created by sanket bhat on 5/3/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import UIKit

class FamilyViewController: UIViewController {

    var awsClient = AWSClient()
    
    @IBOutlet weak var tableView: UITableView!
    var user: User? = nil
    var family: Family? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        OperationQueue.main.addOperation {
            var invites = self.user?.Item?.invitations
                for invite in invites! {
                    let invitationBox = UIAlertController(title: "Invitation", message:"you have invitation to \(invite)", preferredStyle: UIAlertControllerStyle.alert)
                    print("one")
                    invitationBox.addAction(UIAlertAction(title: "Accept", style: .default, handler: {
                        (action)-> Void in
                        print("two")
                        self.user?.Item?.family?.append(invite)
                        self.awsClient.saveUser(user: self.user!){
                            (response) in
                            if response.response == "successful"{
                                    self.tableView.reloadData()
                                    self.user?.Item?.invitations?.removeFirst()
                                    self.awsClient.saveUser(user: self.user!){
                                        (response) in
                                        if response.response == "successful"{
//                                            OperationQueue.main.addOperation {
                                                self.tableView.reloadData()
//                                            }
                                            
                                        }
                                    }
                                }
                                
                            
                        }
                    }))
                    invitationBox.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: nil))
                    
                    self.present(invitationBox, animated: true, completion: nil)
                }

            }
            
        }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addFamily(_ sender: UIBarButtonItem) {
        var inputBox = UIAlertController(title: "Add Family", message:"", preferredStyle: UIAlertControllerStyle.alert)
        inputBox.addTextField(configurationHandler: {
            (textField)-> Void in
        })
        
        inputBox.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            (action) -> Void in
            let familyName = inputBox.textFields![0] as UITextField
            if (self.user?.Item?.family?.contains(familyName.text!))!{
//            self.awsClient.getFamilyDetails(familyID: newFamily.text!){
//                (response) in
//                switch response{
//                case let .success(detail):
//                    if let _ = detail.item {
                        OperationQueue.main.addOperation {
                            let alert = UIAlertController(title: "Family name already taken", message: "try a different name", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        
                    }else{
                        self.awsClient.saveFamily(family: Family(item: Family.Item(familyID: familyName.text!, carts: []))){ (response) in
                            if response.response == "successful"{
                                print("success")
                                self.user!.Item!.family!.append(familyName.text!)
                                self.awsClient.saveUser(user: self.user!){
                                    (response) in
                                    if response.response == "successful"{
                                        OperationQueue.main.addOperation {
                                            let alert = UIAlertController(title: "Family created!!", message: "", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                            self.present(alert, animated: true)
                                            self.tableView.reloadData()
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                    return
//                case let .failure(error):
//
//                    sender.resignFirstResponder()
//                    return
//                }
//            }
        }))
        
        inputBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(inputBox, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? CartViewController{
            controller.user = user!
            controller.family = family!
        }
    }
    
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func Cancel1(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func unwindSegue(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CartViewController {
            // Add a new course
            tableView.reloadData()
        }
    }
    
}

extension FamilyViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (user!.Item!.family!.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "familyCell")!
        cell.textLabel?.text = user!.Item!.family![indexPath.row]
        cell.textLabel?.font = UIFont(name: "Bradley Hand", size: 27)
        return cell
    }
}

extension FamilyViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let familyName = user!.Item!.family![indexPath.row]
        self.awsClient.getFamilyDetails(familyID: familyName){
            (response) in
            switch response{
            case let .success(detail):
                self.family = detail
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "FamilyToCart", sender: self)

                }
            case let .failure(error):
                let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // 1
        let inviteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Invite" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            // 4
            let inviteBox = UIAlertController(title: "Invite", message: "Enter userID to send invite", preferredStyle: .alert)
            inviteBox.addTextField(configurationHandler: {
                (textField)-> Void in
            })
            inviteBox.addAction(UIAlertAction(title: "Send", style: .default, handler: {
                (action) -> Void in
                let userName = inviteBox.textFields![0] as UITextField
                self.awsClient.getUserDetailsforInvite(userID: userName.text!){
                (response) in
                    switch response{
                    case let .success(detail):
                        var userDetail = detail
                        if userDetail.Item != nil{
                            if userDetail.Item?.invitations == nil {
                               userDetail.Item?.invitations = []
                            }
                            userDetail.Item?.invitations?.append(self.user!.Item!.family![indexPath.row])
                            self.awsClient.saveUser(user: userDetail){
                                (response) in
                                if response.response != "successful"{
                                    let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                    self.present(alert, animated: true)
                                }
                                else{
                                    OperationQueue.main.addOperation {
                                        let alert = UIAlertController(title: "Invitation Successfully sent", message: "", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                        self.present(alert, animated: true)
                                    }
                                }
                            }
                        }else{
                            let alert = UIAlertController(title: "Invite unsuccessful", message: "User not found", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }

                        
                    case .failure(_):
                        let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }))
            
            inviteBox.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
//            inviteBox.addAction(appRateAction)
//            inviteBox.addAction(cancelAction)
            
            self.present(inviteBox, animated: true, completion: nil)
        })
        // 5
        return [inviteAction]
    }
    
    
}
