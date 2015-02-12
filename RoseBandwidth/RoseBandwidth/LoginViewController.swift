//
//  LoginViewController.swift
//  Rose-Hulman Bandwidth
//
//  Created by Jonathan Jungck on 1/28/15.
//  Copyright (c) 2015 Jonathan Jungck and Anthony Minardo. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    var managedObjectContext : NSManagedObjectContext?
    var credentials = [LoginCredentials]()
    
    let loginCredentialsIdentifier = "LoginCredentials"
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        updateLoginCredentials()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (credentials.count > 0) {
            var isLogged = credentials[0].isLoggedIn
            if isLogged.boolValue {
                println("Logged :D")
                println(credentials[0].username)
                loadingData(credentials[0])
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNextPage() {
        performSegueWithIdentifier("loginPush", sender: self.loginButton)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func verifyLogin(dataGrabber : DataGrabber) -> Bool {
        if (dataGrabber.isReady) {
            if (dataGrabber.loginSuccessful) {
                println("Login Successful")
                return true
            } else {
                println("Login Failed")
                return false
            }
        }
        return false
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        for dataSet in credentials {
            managedObjectContext?.deleteObject(dataSet)
        }
        
        
        credentials.removeAll(keepCapacity: false);
        
        let newCredentials = NSEntityDescription.insertNewObjectForEntityForName(loginCredentialsIdentifier, inManagedObjectContext: self.managedObjectContext!) as LoginCredentials
        newCredentials.isLoggedIn = false;
        newCredentials.username = username.text
        newCredentials.password = password.text
        
        savedManagedObjectContext()
        updateLoginCredentials()
        
        loadingData(newCredentials)
        
        //println("username: \(credentials[0].username!) password: \(credentials[0].password!)");
        
    }
    
    func loadingData(newCredentials: LoginCredentials){
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
                    self.loadNextPage()
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
                            self.loadNextPage()
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


}
