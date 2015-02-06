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

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        updateLoginCredentials()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        for dataSet in credentials {
            managedObjectContext?.deleteObject(dataSet)
        }
        
        credentials.removeAll(keepCapacity: false);
        
        let newCredentials = NSEntityDescription.insertNewObjectForEntityForName(loginCredentialsIdentifier, inManagedObjectContext: self.managedObjectContext!) as LoginCredentials
        
        newCredentials.username = username.text
        newCredentials.password = password.text
        
        savedManagedObjectContext()
        updateLoginCredentials()
        
        println("username: \(credentials[0].username!) password: \(credentials[0].password!)");
        
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
