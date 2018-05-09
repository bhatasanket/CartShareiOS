//
//  ItemViewController.swift
//  CartShare
//
//  Created by sanket bhat on 5/5/18.
//  Copyright © 2018 sanket bhat. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    var cart: Cart? = nil
    var family: Family? = nil
    var user: User? = nil
    var awsClient = AWSClient()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    @IBAction func addItemAction(_ sender: UIBarButtonItem) {
        var inputBox = UIAlertController(title: "Add Item", message:"", preferredStyle: UIAlertControllerStyle.alert)
        inputBox.addTextField(configurationHandler: {
            (textField)-> Void in
        })
        
        inputBox.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            (action) -> Void in
            let itemName = inputBox.textFields![0] as UITextField
            self.cart?.item?.items?.append(Cart.Item.Items(name: itemName.text, addedBy: self.user?.Item?.firstName, completed: false))
            self.awsClient.saveCart(cart: self.cart!){
                (response) in
                if (response.response != "successful"){
                    let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
            print(itemName.text!)
        }))
        
        inputBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(inputBox, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindSegueToItems(sender: UIStoryboardSegue) {
            tableView.reloadData()
    }
    
    
}

extension ItemViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (cart?.item?.items?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell")!
        let item = cart?.item?.items![indexPath.row]
        if (item?.completed == true) {
            let text = item!.name!
            let textRange = NSMakeRange(0, text.count)
            let attributedText = NSMutableAttributedString(string: (cart?.item?.items![indexPath.row].name!)!)
            attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                        value: NSUnderlineStyle.styleSingle.rawValue,
                                        range: textRange)
            attributedText.addAttribute(NSAttributedStringKey.font,
                                        value: UIFont(name: "Bradley Hand", size: 25),
                                        range: textRange)
            cell.textLabel?.text = ""
            cell.textLabel?.attributedText = attributedText
            cell.textLabel?.font = UIFont(name: "Bradley Hand", size: 25)
            return cell
        }
//        cell.textLabel?.text = cart?.item?.items![indexPath.row].name
        else{
            cell.textLabel?.text = ""
            cell.textLabel?.text = item?.name
            cell.textLabel?.font = UIFont(name: "Bradley Hand", size: 25)
            return cell

        }
    
    }
}
extension ItemViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var detailBox = UIAlertController(title: "Item detail", message:"\(cart?.item?.items![indexPath.row].name!) added by \(cart?.item?.items![indexPath.row].addedBy!)", preferredStyle: UIAlertControllerStyle.alert)
        detailBox.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        self.present(detailBox, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // 1
        let titlemsg = (self.cart?.item?.items![indexPath.row].completed)! ? "Undo" :  "Done"
        let checkAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: titlemsg , handler: { (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            // 2
            let msg = (self.cart?.item?.items![indexPath.row].completed)! ? "UnCheck" :  "Check"
            let checkMenu:UIAlertController?
//            if (self.cart?.item?.items![indexPath.row].completed)! {
//                checkMenu = UIAlertController(title: nil, message: "\(msg) of item", preferredStyle: .actionSheet)
//            }else{
                checkMenu = UIAlertController(title: nil, message: "\(msg) of item", preferredStyle: .actionSheet)
//            }
            let checkAction = UIAlertAction(title: msg, style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                if (self.cart?.item?.items![indexPath.row].completed)!{
                    self.cart?.item?.items![indexPath.row].completed = false
                }
                else{
                    self.cart?.item?.items![indexPath.row].completed = true
                }
                tableView.reloadData()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            
            checkMenu?.addAction(checkAction)
            checkMenu?.addAction(cancelAction)
            
            self.present(checkMenu!, animated: true, completion: nil)
        })
        // 3
        let rateAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            // 4
            let rateMenu = UIAlertController(title: nil, message: "Delete this Item", preferredStyle: .actionSheet)
            
            let appRateAction = UIAlertAction(title: "Delete Item", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
                self.cart?.item?.items?.remove(at: indexPath.row)
                tableView.reloadData()
                self.awsClient.saveCart(cart: self.cart!){
                    (response) in
                    if (response.response != "successful"){
                        let alert = UIAlertController(title: "something went wrong", message: "Please try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        tableView.reloadData()
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            
            rateMenu.addAction(appRateAction)
            rateMenu.addAction(cancelAction)
            
            self.present(rateMenu, animated: true, completion: nil)
        })
        // 5
        return [checkAction,rateAction]
    }
}
