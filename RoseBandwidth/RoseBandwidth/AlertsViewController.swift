//
//  AlertsTableViewController.swift
//  Rose-Hulman Bandwidth
//
//  Created by Jonathan Jungck on 2/1/15.
//  Copyright (c) 2015 Jonathan Jungck and Anthony Minardo. All rights reserved.
//

import UIKit
import CoreData

class AlertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var alertTableView: UITableView!
    
    var managedObjectContext : NSManagedObjectContext?

    var backButton = UIBarButtonItem()
    
    var alerts = [Alerts]()
    
    let alertsIdentifier = "Alerts"

    var alertCellIdentifier = "alertCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        //backButton = self.navigationItem.leftBarButtonItem!
//        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "showEditAlertsView"), animated: true)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "showEditAlertsView"), animated: true)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        //var newAlert = Alerts()
        let newAlert = NSEntityDescription.insertNewObjectForEntityForName(alertsIdentifier, inManagedObjectContext: self.managedObjectContext!) as Alerts
        newAlert.alertName = "8 GB"
        newAlert.threshold = 1.0
        newAlert.isEnabled = true
        
        alerts.append(newAlert)
        
        newAlert.alertName = "75%"
        newAlert.threshold = 0.75
        newAlert.isEnabled = false
        
        alerts.append(newAlert)
        
        
        //self.navigationItem.
        //self.navigationItem.title. = @"Alerts"
        
        //self.navigationItem.title = @"Alerts View"
        
        //navigationController.setNavigationBarHidden(false, animated:true)
        /*
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        myBackButton.addTarget(self, action: "Settings", forControlEvents: UIControlEvents.TouchUpInside)
        
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem = myCustomBackButtonItem
        */

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func showEditAlertsView() {
//        backButton = self.navigationController?.navigationItem.leftBarButtonItem!
        alertTableView.setEditing(true, animated: true)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "hideEditAlertsView"), animated: true)
        
    }
    
    func hideEditAlertsView() {
        alertTableView.setEditing(false, animated: true)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "showEditAlertsView"), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return alerts.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(alertCellIdentifier, forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        
        

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            alerts.removeAtIndex(indexPath.item)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
