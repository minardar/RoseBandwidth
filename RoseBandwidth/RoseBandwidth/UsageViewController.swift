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
    
    func updateView() {
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
        received = received.substringToIndex(received.endIndex.predecessor().predecessor().predecessor())
        var recNoComma = NSString(string: received).stringByReplacingOccurrencesOfString(",", withString: "")
        var rec : Float = NSString(string: recNoComma).floatValue
        rec = rec / 8000
        
        receivedBar.setProgress(rec, animated: true)
        receivedPercent.text = String(format: "%.1f%%", rec*100)
        
        var sent : String = overview[0].sentData
        sentLabel.text = sent
        sent = sent.substringToIndex(sent.endIndex.predecessor().predecessor().predecessor())
        var senNoComma = NSString(string: sent).stringByReplacingOccurrencesOfString(",", withString: "")
        var sen : Float = NSString(string: senNoComma).floatValue
        sen = sen / 8000
        
        sentBar.setProgress(sen, animated: true)
        sentPercent.text = String(format: "%.1f%%", sen*100)
    }
    
    func fetchOverview() {
        let fetchRequest = NSFetchRequest(entityName: usageIdentifier)
        
        var error : NSError? = nil
        overview = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as [DataOverview]
        
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
