//
//  UsageViewController.swift
//  Rose-Hulman Bandwidth
//
//  Created by Jonathan Jungck on 1/28/15.
//  Copyright (c) 2015 Jonathan Jungck and Anthony Minardo. All rights reserved.
//

import UIKit

var managedObjectContext : NSManagedObjectContext?
var overview = [DataOverview]()
let usageIdentifier = "DataOverview"
var credentials = [LoginCredentials]()

class UsageViewController: UIViewController {
    @IBOutlet weak var receivedBar: UIProgressView!
    @IBOutlet weak var sentBar: UIProgressView!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var receivedPercent: UILabel!
    @IBOutlet weak var sentPercent: UILabel!
    @IBOutlet weak var bandwidthClass: UILabel!
    @IBOutlet weak var classStatus: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        fetchOverview()
        updateView()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchOverview()
        updateView()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    @IBOutlet weak var refreshPressed: UIBarButtonItem!
    
    @IBAction func refreshPressed(sender: UIBarButtonItem) {
        updateLoginCredentials()
        loadingData(credentials[0])
    }
    func updateView() {
        fetchOverview()
        var bandwidth : String = overview[0].bandwidthClass
        bandwidthClass.text = bandwidth
        if bandwidth == "1024k" {
            classStatus.image = UIImage(named: "yellowlight.png")
            receivedBar.progressTintColor = UIColor(red: 221/255, green: 229/255, blue: 10/255, alpha: 1)
            sentBar.progressTintColor = UIColor(red: 221/255, green: 229/255, blue: 10/255, alpha: 1)
        } else if bandwidth == "256k" {
            classStatus.image = UIImage(named: "redlight.png")
            receivedBar.progressTintColor = UIColor(red: 227/255, green: 36/255, blue: 5/255, alpha: 1)
            sentBar.progressTintColor = UIColor(red: 227/255, green: 36/255, blue: 5/255, alpha: 1)
        }
        
        var received : String = overview[0].recievedData
        receivedLabel.text = received
        println("Label changed to \(received)")
        received = received.substringToIndex(received.endIndex.predecessor().predecessor().predecessor())
        var recNoComma = NSString(string: received).stringByReplacingOccurrencesOfString(",", withString: "")
        var rec : Float = NSString(string: recNoComma).floatValue
        rec = rec / 8000
        
        //receivedBar.setProgress(rec, animated: false)
        receivedBar.progress = rec;
        receivedBar.updateConstraints()
        receivedPercent.text = String(format: "%.1f%%", rec*100)
        
        var sent : String = overview[0].sentData
        sentLabel.text = sent
        sent = sent.substringToIndex(sent.endIndex.predecessor().predecessor().predecessor())
        var senNoComma = NSString(string: sent).stringByReplacingOccurrencesOfString(",", withString: "")
        var sen : Float = NSString(string: senNoComma).floatValue
        sen = sen / 8000
        println("New: \(sen)")
        //sentBar.setProgress(sen, animated: false)
        sentBar.progress = sen;
        sentBar.updateConstraints()
        sentPercent.text = String(format: "%.1f%%", sen*100)
    }
    
    func updateLoginCredentials() {
        let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
        
        var error : NSError? = nil
        credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as [LoginCredentials]
        
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
        
    }
    
    func savedManagedObjectContext() {
        var error : NSError?
        
        managedObjectContext?.save(&error)
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
    }
    
    func verifyLogin(dataGrabber : DataGrabber) -> Bool {
        if (dataGrabber.isReady) {
            if (dataGrabber.loginSuccessful) {
                println("Login Successful")
                println(credentials[0].username)
                return true
            } else {
                println("Login Failed")
                return false
            }
        }
        return false
    }
    
    func loadingData(newCredentials: LoginCredentials){
        
        let fetchRequest2 = NSFetchRequest(entityName: devicesIdentifier)
        
        var error2 : NSError? = nil
        var devices = managedObjectContext?.executeFetchRequest(fetchRequest2, error: &error2) as [DataDevice]
        for index2 in devices {
            managedObjectContext?.deleteObject(index2)
        }
        
        let fetchRequest3 = NSFetchRequest(entityName: overviewIdentifier)
        
        var error3 : NSError? = nil
        var overview = managedObjectContext?.executeFetchRequest(fetchRequest3, error: &error3) as [DataOverview]
        
        for index3 in overview {
            managedObjectContext?.deleteObject(index3)
        }
        
        
        savedManagedObjectContext()
        
        
        
        
        var dataGrabber = DataGrabber(login: credentials[0])
        
        let loadingController = UIAlertController(title: "Connecting...", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (_) -> Void in
            loadingController.dismissViewControllerAnimated(true, completion: nil)
            dataGrabber.cancelledAttempt = true
            dataGrabber.killConnection()
        }
        
        loadingController.addAction(cancelAction)
        
        let loginFailController = UIAlertController(title: "Login Failed", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        loginFailController.addAction(okAction)
        
        presentViewController(loadingController, animated: true, completion: nil)
        
        delay(5) {
            if (dataGrabber.cancelledAttempt) {
                return
            }
            if(self.verifyLogin(dataGrabber)) {
                println("Pushing")
                loadingController.dismissViewControllerAnimated(true) {
                    newCredentials.isLoggedIn = true
                    self.savedManagedObjectContext()
                    self.updateView()
                }
            } else {
                self.delay(5) {
                    if (dataGrabber.cancelledAttempt) {
                        println("Cancelled")
                        loadingController.dismissViewControllerAnimated(true, completion: nil)
                        return
                    }
                    if(self.verifyLogin(dataGrabber)) {
                        println("Pushing")
                        loadingController.dismissViewControllerAnimated(true) {
                            newCredentials.isLoggedIn = true
                            self.savedManagedObjectContext()
                            self.updateView()
                        }
                    } else {
                        println("Failure")
                        loadingController.dismissViewControllerAnimated(true, completion: nil)
                        self.presentViewController(loginFailController, animated: true, completion: nil)
                        dataGrabber.killConnection()
                        
                    }
                }
            }
        }
    }
    
    func fetchOverview() {
        let fetchRequest = NSFetchRequest(entityName: usageIdentifier)
        
        var error : NSError? = nil
        overview = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as [DataOverview]
        
        
        println(overview[0].recievedData)
        
        
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
