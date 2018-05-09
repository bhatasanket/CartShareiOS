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
            if (self.user?.item?.family?.contains(familyName.text!))!{
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
                                self.user!.item!.family!.append(familyName.text!)
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
        return (user!.item!.family!.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "familyCell")!
        cell.textLabel?.text = user!.item!.family![indexPath.row]
        cell.textLabel?.font = UIFont(name: "Bradley Hand", size: 27)
        return cell
    }
}

extension FamilyViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let familyName = user!.item!.family![indexPath.row]
        self.awsClient.getFamilyDetails(familyID: familyName){
            (response) in
            switch response{
            case let .success(detail):
                self.family = detail
                self.performSegue(withIdentifier: "FamilyToCart", sender: self)
            case let .failure(error):
                let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.tableView.reloadData()
            }
        }
    }
}
