//
//  DataGrabber.swift
//  RoseBandwidth
//
//  Created by Jonathan Jungck on 2/9/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//
import UIKit
import CoreData

class DataGrabber: NSObject {

    let myURLString : NSString
    let myURL : NSURL?
    var conn: NSURLConnection?
    var request : NSMutableURLRequest?
    var data: NSMutableData = NSMutableData()
    var login : LoginCredentials?
    var managedObjectContext : NSManagedObjectContext? 
    
    let dataOverviewIdentifier = "DataOverview"
    let dataDeviceIdentifier = "DataDevice"
    
    var overviews = [DataOverview]()
    var devices = [DataDevice]()
    var isReady = false
    var loginSuccessful = false
    var cancelledAttempt = false

    override init() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        myURLString = "http://netreg.rose-hulman.edu/tools/networkUsage.pl"
        super.init()
        myURL = NSURL(string: myURLString)
        if myURL != nil {
            println(myURL)
            request = NSMutableURLRequest(URL: myURL!)
            conn = NSURLConnection(request: request!, delegate: self)
            conn?.start()
        }
    }
    
    func killConnection() {
        conn?.cancel()
    }
    
    convenience init(login : LoginCredentials) {
        self.init()
        self.login = login
        println(login.password+" "+login.username);
    }
    
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        println("Failed with error:\(error.localizedDescription)")
    }
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge!){
        if login != nil {
            var authentication: NSURLCredential = NSURLCredential(user: login!.username, password: login!.password, persistence: NSURLCredentialPersistence.ForSession)
            challenge.sender.useCredential(authentication, forAuthenticationChallenge: challenge)
        }
    }
    
    //NSURLConnection delegate method
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        //New request so we need to clear the data object
        
        self.data = NSMutableData()
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        //Append incoming data
        self.data.appendData(data)

        
    }
    
    //NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        //println(self.data)
        var error: NSError?
        let myHTMLString = NSString(contentsOfURL: myURL!, encoding: NSUTF8StringEncoding, error: &error)
        
        if let error = error {
            println("Error : \(error)")
        } else {
            //println("HTML : \(myHTMLString)")
        }
        
        
        var err : NSError?
        var parser     = HTMLParser(html: myHTMLString!, error: &err)
        if err != nil {
            println(err)
            exit(1)
        } else {
            var items = parser.body?.findChildTags("td")
            var i = 0
            for item in items! {
                println("\(i): \(item.contents)")
                i++
            }
            if items != nil {
                
                var array = items!
                
                //Gather old data
                updateData()
                
                //Delete any old data
                for i in 0..<overviews.count {
                    managedObjectContext?.deleteObject(overviews[i])
                }
                for i in 0..<devices.count {
                    managedObjectContext?.deleteObject(devices[i])
                }
                
                //Set overview data
                var newOverview = NSEntityDescription.insertNewObjectForEntityForName(dataOverviewIdentifier, inManagedObjectContext: self.managedObjectContext!) as DataOverview
                newOverview.bandwidthClass = array[16].contents
                newOverview.recievedData = array[17].contents
                newOverview.sentData = array[18].contents
                overviews.append(newOverview)
                
                var numDevices = (array.count - 28)/7
                
                for i in 0..<numDevices {
                    var device = [NSString]()
                    
                    //Set devices data
                    var newDevice = NSEntityDescription.insertNewObjectForEntityForName(dataDeviceIdentifier, inManagedObjectContext: self.managedObjectContext!) as DataDevice
                    newDevice.addressIP = array[28+7*i].contents
                    newDevice.hostName = array[29+7*i].contents
                    newDevice.recievedData = array[31+7*i].contents
                    newDevice.sentData = array[32+7*i].contents
                    devices.append(newDevice)
                }
                
            }
            
        }
        NSLog("connectionDidFinishLoading");
        isReady = true
        loginSuccessful = true
    }

    func updateData() {
        let fetchRequestDevices = NSFetchRequest(entityName: dataDeviceIdentifier)
        let fetchRequestOverview = NSFetchRequest(entityName: dataOverviewIdentifier)
        
        var error : NSError? = nil
        devices = managedObjectContext?.executeFetchRequest(fetchRequestDevices, error: &error) as [DataDevice]
        overviews = managedObjectContext?.executeFetchRequest(fetchRequestOverview, error: &error) as [DataOverview]
        
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


    func grabData(){
        var error: NSError?
        let myHTMLString = NSString(contentsOfURL: myURL!, encoding: NSUTF8StringEncoding, error: &error)
        
        if let error = error {
            println("Error : \(error)")
        } else {
            println("HTML : \(myHTMLString)")
        }
        
        
        var err : NSError?
        var parser     = HTMLParser(html: myHTMLString!, error: &err)
        if err != nil {
            println(err)
            exit(1)
        }

    }

}
