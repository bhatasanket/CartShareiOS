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
        if let sourceViewController = sender.source as? NewFamilyViewController {
            // Add a new course
            print(sourceViewController.newFamily.text!)
            user!.item!.family!.append(sourceViewController.newFamily.text!)
            awsClient.saveUser(user: user!){
                (response) in
                if response.response == "successful"{
                    OperationQueue.main.addOperation {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
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
