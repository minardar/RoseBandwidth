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

class DataGrabber: NSObject {

    let myURLString : NSString
    let myURL : NSURL?
    var conn: NSURLConnection?
    var request : NSMutableURLRequest?
    var data: NSMutableData = NSMutableData()

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
    
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        println("Failed with error:\(error.localizedDescription)")
    }
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge!){
        var authentication: NSURLCredential = NSURLCredential(user: "", password: "", persistence: NSURLCredentialPersistence.ForSession)
        challenge.sender.useCredential(authentication, forAuthenticationChallenge: challenge)
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
            println("HTML : \(myHTMLString)")
        }
        
        
        var err : NSError?
        var parser     = HTMLParser(html: myHTMLString!, error: &err)
        if err != nil {
            println(err)
            exit(1)
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
