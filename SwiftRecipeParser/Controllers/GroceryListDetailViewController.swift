//
//  GroceryListDetailViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class GroceryListDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddGroceryListItemDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    var groceryList:GroceryList!
    
    lazy private var databaseInterface:DatabaseInterface = {
       return DatabaseInterface()
    }()
    
    override func encodeRestorableStateWithCoder(aCoder: NSCoder) {
        super.encodeRestorableStateWithCoder(aCoder)
        aCoder.encodeObject(groceryList.name, forKey: "groceryListName")
    }
    
    override func decodeRestorableStateWithCoder(aDecoder: NSCoder) {
        super.decodeRestorableStateWithCoder(aDecoder)
        guard let groceryListName = aDecoder.decodeObjectForKey("groceryListName") as? String else { return }
        groceryList = GroceryList.returnGroceryListWithName(groceryListName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationItem.title = groceryList.name
        totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func groceryListItemAdded(groceryListItem: GroceryListItem) {
        if groceryList.hasItems.containsObject(groceryListItem) {
            if #available(iOS 8.0, *) {
                Utilities.showOkButtonAlert(self, title: "Error Alert", message: "\(groceryListItem.name) is already on your list", okButtonHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            groceryList.totalCost = NSNumber(float:groceryList.totalCost.floatValue + groceryListItem.cost.floatValue)
            totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
            groceryList.addHasItemsObject(groceryListItem)
            databaseInterface.saveContext()
        }
    }

    @IBAction func clearTotalButtonPressed(sender: AnyObject) {
        groceryList.totalCost = NSNumber(float:0.0)
        databaseInterface.saveContext()
        totalCostLabel.text = "Total Cost: $0.00"
    }
    
    @IBAction func clearAllItemsButtonPressed(sender: AnyObject) {
        if #available(iOS 8.0, *) {
            Utilities.showYesNoAlert(self, title: "Do you want to clear all the items in this grocery list?", message: "", yesButtonHandler: { action in
                self.groceryList.hasItems.enumerateObjectsUsingBlock({ (groceryListObject, idx, stop) -> Void in
                    let groceryListItem = groceryListObject as! GroceryListItem
                    groceryListItem.isBought = false
                    self.groceryList.totalCost = NSNumber(float:self.groceryList.totalCost.floatValue - groceryListItem.cost.floatValue)
                })
                self.groceryList.removeAllHasItemsObjects()
                self.databaseInterface.saveContext()
                self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction func buyItemButtonPressed(sender: AnyObject) {
        let buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView:tableView)
        let indexPath:NSIndexPath?  = tableView!.indexPathForRowAtPoint(buttonPosition)
        guard indexPath != nil else { return }
        
        guard let itemToBuy:GroceryListItem = groceryList.hasItems[indexPath!.row] as? GroceryListItem else { return }
        
        if itemToBuy.isBought.boolValue {
            if #available(iOS 8.0, *) {
                Utilities.showYesNoAlert(self, title: "Do you want to put back \(itemToBuy.name)?", message: "", yesButtonHandler: { action in
                    (self.groceryList.hasItems[indexPath!.row] as! GroceryListItem).isBought = false
                    self.groceryList.totalCost = NSNumber(float:self.groceryList.totalCost.floatValue - itemToBuy.cost.floatValue)
                    self.databaseInterface.saveContext()
                    
                    self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
                    self.tableView.reloadData()
                })
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            var textField:UITextField = UITextField()
            var startingText = ""
            if (itemToBuy.cost.floatValue > 0.0) {
                startingText = String(format: "%.2f", itemToBuy.cost.floatValue);
            }
            if #available(iOS 8.0, *) {
                Utilities.showTextFieldAlert(self, title: "Enter price of \(itemToBuy.name)", message: "", inputTextField: &textField, startingText: startingText, keyboardType: .DecimalPad, capitalizationType:.None, okButtonHandler: { action in
                    if textField.text != "" {
                        let itemToBuyCost:Float = (textField.text as NSString!).floatValue
                        (self.groceryList.hasItems[indexPath!.row] as! GroceryListItem).cost = NSNumber(float:itemToBuyCost)
                        (self.groceryList.hasItems[indexPath!.row] as! GroceryListItem).isBought = true
                        
                        self.groceryList.totalCost = NSNumber(float:self.groceryList.totalCost.floatValue + itemToBuyCost)
                        self.databaseInterface.saveContext()
                        
                        self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
                        self.tableView.reloadData()
                    }
                    else {
                        Utilities.showOkButtonAlert(self, title: "Please enter a price", message: "", okButtonHandler: nil)
                    }
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addGroceryListItemSegue" {
            let addViewController:AddGroceryListItemViewController = segue.destinationViewController as! AddGroceryListItemViewController
            addViewController.delegate = self
        }
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard groceryList != nil else { return 0 }
        return groceryList.hasItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroceryListItemCell", forIndexPath: indexPath) 
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let itemToPutBack = groceryList.hasItems[indexPath.row] as? GroceryListItem {
                groceryList.totalCost = NSNumber(float:groceryList.totalCost.floatValue - itemToPutBack.cost.floatValue)
                totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
                groceryList.removeHasItemsObject(itemToPutBack)
                databaseInterface.saveContext()
                tableView.reloadData()
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let groceryListItemCell = cell as! GroceryListItemTableViewCell
        let groceryListItem = groceryList.hasItems[indexPath.row] as! GroceryListItem
        groceryListItemCell.groceryListItemName.text = groceryListItem.name
        groceryListItemCell.groceryListItemCost.text = String(format: "%.2f", groceryListItem.cost.floatValue)
        if groceryListItem.isBought.boolValue {
            groceryListItemCell.groceryListItemButton.setTitle("Put Back", forState: .Normal)
            groceryListItemCell.groceryListItemName.textColor = UIColor.redColor()
        }
        else {
            groceryListItemCell.groceryListItemButton.setTitle("Buy", forState: .Normal)
            groceryListItemCell.groceryListItemName.textColor = UIColor.blackColor()
        }
    }
    
}
