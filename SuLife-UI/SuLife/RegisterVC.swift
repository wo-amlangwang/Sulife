//
//  RegisterVC.swift
//  SuLife
//
//  Created by Sine Feng on 10/12/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    @IBOutlet weak var userFisrtNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userRepeatPasswordTextField: UITextField!
    
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
    
    @IBAction func registerButtonTapped(sender: UIButton) {
        
        let userFirstName = userFisrtNameTextField.text!
        let userLastName = userLastNameTextField.text!
        let userEmail = userEmailTextField.text!
        let userPassword = userPasswordTextField.text!
        let userRepeatPassword = userRepeatPasswordTextField.text!
        
        // Check for empty fields
        if (userFirstName.isEmpty || userLastName.isEmpty || userEmail.isEmpty || userPassword.isEmpty || userRepeatPassword.isEmpty)
        {
            // Display alert message and return
            displayAlertMessage("Fill Up Required Fields")
        }
        
        // Check password && repeat password
        else if (userPassword != userRepeatPassword)
        {
            // Display alert message and return
            displayAlertMessage("Password Does Not Match")
        }
        
        // TODO: Store users data (send to server side)
        
        else
        {
            do {
                
                let post:NSString = "email=\(userEmail)&password=\(userPassword)"
                
                NSLog("PostData: %@",post);
                
                let url:NSURL = NSURL(string: "https://damp-retreat-5682.herokuapp.com/register")!
                
                let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
                
                let postLength:NSString = String( postData.length )
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                
                
                
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
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        
                        let success:NSString = jsonData.valueForKey("message") as! NSString
                        let mytoken:NSString = jsonData.valueForKey("Access_Token") as! NSString
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %@", success);
                        NSLog("token is : %@", mytoken);
                        if(success == "OK")
                        {
                            NSLog("Sign Up SUCCESS");
                            
                            let myAlert = UIAlertController(title: "Registration Successful", message: "Hi \(userFirstName)! Welcom do SuLife!", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil)
                            myAlert.addAction(okAction)
                            self.presentViewController(myAlert, animated:true, completion:nil)

                            //======================================
                            // Send firstName & lastName to database
                            //======================================
                            
                            sendUserPrfileToDB(mytoken, firstname: userLastName, lastname: userFirstName)
                            
                            //=======================================
                            // Auot login
                            //=======================================
                            autoLogin(userEmail, userPassword: userPassword)
                        }
                        else
                        {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign Up Failed!"
                            alertView.message = error_msg as String
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                            
                        }
                        
                    }
                    else
                    {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = "Email already exist! Try login!"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                }
                else
                {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign in Failed!"
                    alertView.message = "Connection Failure"
                    if let error = reponseError {
                        alertView.message = (error.localizedDescription)
                    }
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }
            catch
            {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign Up Failed!"
                alertView.message = "Server Error!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
    }

    func displayAlertMessage(userMessage:String)
    {
        var myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated:true, completion:nil)
    }
    
    
    //======================================
    // Send firstName & lastName to database
    //======================================
    
    func sendUserPrfileToDB(token:NSString, firstname:String, lastname:String)
    {
        do {
            let post:NSString = "fistname=\(firstname)&lastname=\(lastname)"
            
            NSLog("PostData: %@",post);
            
            let url:NSURL = NSURL(string: "https://damp-retreat-5682.herokuapp.com/profile")!
            
            let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(token as String, forHTTPHeaderField: "x-access-token")
            
            
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
                    
                    //var error: NSError?
                }
            }
        }
    }
    
    //==================================
    // Auto login
    //==================================
    func autoLogin (userEmail: String, userPassword: String) {
        do {
            let post:NSString = "email=\(userEmail)&password=\(userPassword)"
            
            NSLog("PostData: %@",post);
            
            let url:NSURL = NSURL(string:"https://damp-retreat-5682.herokuapp.com/local/login")!
            
            let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
            
            let postLength:NSString = String( postData.length )
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            
            var reponseError: NSError?
            var response: NSURLResponse?
            
            var urlData: NSData?
            do {
                urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
            } catch let error as NSError {
                reponseError = error
                urlData = nil
            }
            
            if ( urlData != nil )
            {
                let res = response as! NSHTTPURLResponse!;
                if (res != nil)
                {
                    NSLog("Response code: %ld", res.statusCode);
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        
                        let success:NSString = jsonData.valueForKey("message") as! NSString
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %@", success);
                        
                        if(success == "OK")
                        {
                            NSLog("Login SUCCESS");
                            
                            // store information as globa
                            
                            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            prefs.setObject(userEmail, forKey: "Email")
                            prefs.setInteger(1, forKey: "isUserLoggedIn")
                            prefs.synchronize()
                            
                            self.performSegueWithIdentifier("registerToMain", sender: self)
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign in Failed!"
                            alertView.message = error_msg as String
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                    }
                } else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign in Failed!"
                    alertView.message = "Please check your Email and Password!\nIf you haven't registered,\ntry register first!"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            } else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection fail!"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        } catch {
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "Server Error"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }

    @IBAction func iHaveAnAccountButtonTapped(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


}
