//
//  CartViewController.swift
//  CartShare
//
//  Created by sanket bhat on 5/5/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {

    var awsClient = AWSClient()
    var user:User? = nil
    var family: Family? = nil
    var selectedCart: Cart? = nil
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func addCartAction(_ sender: UIBarButtonItem) {
        var inputBox = UIAlertController(title: "Add Cart", message:"", preferredStyle: UIAlertControllerStyle.alert)
        inputBox.addTextField(configurationHandler: {
            (textField)-> Void in
        })
        
        inputBox.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            (action) -> Void in
            let cartName = inputBox.textFields![0] as UITextField
            self.awsClient.saveCart(cart: Cart(item: Cart.Item(items: [], cartID: cartName.text, familyID: self.family?.item?.familyID))){
                (response) in
                if (response.response != "successful"){
                    let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }else{
                    self.family?.item?.carts?.append(cartName.text!)
                    self.awsClient.saveFamily(family: self.family!){
                        (response) in
                        if (response.response != "successful"){
                            let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }else{
                            OperationQueue.main.addOperation {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
                
            }
        }))
        
        inputBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(inputBox, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? ItemViewController{
            controller.user = user!
            controller.family = family!
            controller.cart = selectedCart!
        }
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel1(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func unwindSegue1(sender: UIStoryboardSegue) {
//        if let _ = sender.source as? ItemViewController {
            // Add a new course
            tableView.reloadData()
//        }
    }
    
    
}

extension CartViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (family?.item?.carts?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell")!
        cell.textLabel?.text = ""
        cell.textLabel?.font = UIFont(name: "Bradley Hand", size: 27)
        cell.textLabel?.text = family?.item?.carts![indexPath.row]

        return cell
    }
    
    
}

extension CartViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        awsClient.getCartDetails(cartID: family!.item!.carts![indexPath.row], familyID: family!.item!.familyID!){
            (response) in
            switch response{
            case let .success(detail):
                self.selectedCart = detail
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "cartToItem", sender: self)
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
        
        // 3
        let rateAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: {
            (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            self.awsClient.deleteCart(cartID: (self.family?.item?.carts![indexPath.row])!, familyID: (self.family?.item?.familyID)!){
                (response) in
                if response.response == "successful"{
                    self.family?.item?.carts?.remove(at: indexPath.row)
                    self.awsClient.saveFamily(family: self.family!){
                        (response) in
                        if response.response != "successful"{
                            let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        })
        // 5
        return [rateAction]
    }
}
