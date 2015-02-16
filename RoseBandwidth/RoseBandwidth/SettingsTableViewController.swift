//
//  SettingsTableViewController.swift
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/11/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import UIKit
import CoreData

let logoutIdentifier = "logoutSegue"
let loginCredentialsIdentifier = "LoginCredentials"
let devicesIdentifier = "DataDevice"
let overviewIdentifier = "DataOverview"
let alertsIdentifier = "Alerts"

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var logoutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
        
        var error : NSError? = nil
        var credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as [LoginCredentials]
        
        var error2 : NSError? = nil
        let fetchRequest2 = NSFetchRequest(entityName: alertsIdentifier)
        var alerts = managedObjectContext?.executeFetchRequest(fetchRequest2, error: &error) as [Alerts]
        
        var count = 0
        if credentials.count > 0 {
            if alerts.count > 0 {
                for alert in alerts {
                    if ((alert.username == credentials[0].username) && (alert.isEnabled.boolValue)){
                        count++
                    }
                }
            }
        }
        
        self.tableView(self.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)).detailTextLabel?.text = count != 1 ? "\(count) alerts" : "\(count) alert"
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        }
        return 0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
            
            var error : NSError? = nil
            var credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as [LoginCredentials]
            
            if error != nil {
                println("There was an unresolved error: \(error?.userInfo)")
                abort()
            }
            
            for index in credentials {
                managedObjectContext?.deleteObject(index)
            }
            
            let fetchRequest2 = NSFetchRequest(entityName: devicesIdentifier)
            
            var error2 : NSError? = nil
            var devices = managedObjectContext?.executeFetchRequest(fetchRequest2, error: &error) as [DataDevice]
            
            for index2 in devices {
                managedObjectContext?.deleteObject(index2)
            }
            
            let fetchRequest3 = NSFetchRequest(entityName: overviewIdentifier)
            
            var error3 : NSError? = nil
            var overview = managedObjectContext?.executeFetchRequest(fetchRequest3, error: &error) as [DataOverview]
            
            for index3 in overview {
                managedObjectContext?.deleteObject(index3)
            }
            
            
            savedManagedObjectContext()            
            performSegueWithIdentifier(logoutIdentifier, sender: self)

        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
        
        var error : NSError? = nil
        var credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as [LoginCredentials]
        
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
        if section == 0 {
            return "ALERTS"
        } else if section == 1 {
            return "ACCOUNT ACTIONS"
        }
        else {
            return "LOGGED IN AS \(credentials[0].username)"
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    
    func savedManagedObjectContext() {
        var error : NSError?
        
        managedObjectContext?.save(&error)
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
    }

}
