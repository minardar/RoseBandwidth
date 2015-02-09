//
//  DataGrabber.swift
//  RoseBandwidth
//
//  Created by Jonathan Jungck on 2/9/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

/*
// Setup NSURLConnection
NSURL *URL = [NSURL URLWithString:url];
NSURLRequest *request = [NSURLRequest requestWithURL:URL
cachePolicy:NSURLRequestUseProtocolCachePolicy
timeoutInterval:30.0];

NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
[connection start];
[connection release];

// NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
if ([challenge previousFailureCount] == 0) {
NSLog(@"received authentication challenge");
NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"USER"
password:@"PASSWORD"
persistence:NSURLCredentialPersistenceForSession];
NSLog(@"credential created");
[[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
NSLog(@"responded to authentication challenge");
}
else {
NSLog(@"previous authentication failure");
}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
...
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
...
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
...
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
...
}
*/

import UIKit
import CoreData

class DataGrabber: NSObject {

    let myURLString : NSString
    let myURL : NSURL?
    var conn: NSURLConnection?
    var request : NSMutableURLRequest?
    var data: NSMutableData = NSMutableData()
    var login : LoginCredentials?

    override init() {
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
    
    convenience init(login : LoginCredentials) {
        self.init()
        self.login = login
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
                var overview = [NSString]()
                overview.append(array[16].contents)
                overview.append(array[17].contents)
                overview.append(array[18].contents)
                
                var numDevices = (array.count - 28)/7
                
                for i in 0..<numDevices {
                    var device = [NSString]()
                    device.append(array[28+7*i].contents)
                    device.append(array[29+7*i].contents)
                    device.append(array[31+7*i].contents)
                    device.append(array[32+7*i].contents)
                    println(device)
                }
                
            }
            
        }
        NSLog("connectionDidFinishLoading");
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
