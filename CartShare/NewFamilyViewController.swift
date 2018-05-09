//
//  NewFamilyViewController.swift
//  CartShare
//
//  Created by sanket bhat on 5/5/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import UIKit

class NewFamilyViewController: UIViewController {

    var awsClient = AWSClient()
    
    @IBOutlet weak var bttnMAke: UIButton!
    @IBOutlet weak var newFamily: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func makeFamily(_ sender: UIButton) {
        self.awsClient.getFamilyDetails(familyID: newFamily.text!){
            (response) in
            switch response{
            case let .success(detail):
                if let _ = detail.item {
                OperationQueue.main.addOperation {
                let alert = UIAlertController(title: "Family name already taken", message: "try a different name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.newFamily.text = ""

                    self.newFamily.becomeFirstResponder()
                    }
                    
                }else{
                    self.awsClient.saveFamily(family: Family(item: Family.Item(familyID: self.newFamily.text!, carts: []))){ (response) in
                        if response.response == "successful"{
                            print("success")
                            OperationQueue.main.addOperation {
                                let alert = UIAlertController(title: "Family created!!", message: "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                self.present(alert, animated: true)
                                self.bttnMAke.isEnabled = false
                                self.bttnMAke.isHidden = true
                                self.newFamily.isHidden = true
                                self.newFamily.isEnabled = false
                            }
                        }
                        
                    }
                }
                return
            case let .failure(error):
                
                sender.resignFirstResponder()
                return
            }
        }
        
        

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
