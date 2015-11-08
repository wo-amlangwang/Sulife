//
//  NewEventVC.swift
//  SuLife
//
//  Created by Sine Feng on 10/16/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit



class NewEventVC: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func addEventTapped(sender: UIButton) {
        
        // TODO SERVER
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        var eventList: NSMutableArray? = userDefaults.objectForKey("eventList") as? NSMutableArray
        
        let eventTitle = titleTextField.text!
        let eventDetail = detailTextField.text!
        let eventStart = startTimeTextField.text!
        let eventEnd = endTimeTextField.text!
        
        let post:NSString = "title=\(eventTitle)&detail=\(eventDetail)&starttime=\(eventStart)&endtime=\(eventEnd)"
        
        NSLog("PostData: %@",post);
        
        let url:NSURL = NSURL(string: eventURL)!
        
        let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        
        let postLength:NSString = String( postData.length )
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(accountToken as String, forHTTPHeaderField: "x-access-token")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData?
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
        } catch let error as NSError {
            reponseError = error
            urlData = nil
        }
        
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                NSLog("Response ==> %@", responseData);
                
                var error: NSError?
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(urlData!, options: []) as? NSDictionary {
                        
                        let success:NSString = jsonResult.valueForKey("message") as! NSString
                        
                        if (success == "OK") {
                            NSLog("Add Event Successfully")
                        self.performSegueWithIdentifier("newToEventsTable", sender: self)
                            
                        } else {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Add New Event Failed!"
                            alertView.message = "Please Try Again!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                        
                    }
                } catch {
                    print(error)
                }
                
                
                
                //[jsonData[@"success"] integerValue];
                
            } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Add New Event Failed!"
                alertView.message = "System Error!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
            
        } else {
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Add New Event Failed!"
            alertView.message = "Response Error!"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }

}
