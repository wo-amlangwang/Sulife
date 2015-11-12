//
//  EventsTVC.swift
//  SuLife
//
//  Created by Sine Feng on 10/16/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class EventTableVC: UITableViewController, UISearchBarDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var EventList: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    var resArray : [NSDictionary] = []
    // Sine
    var searchResults : [String] = []
    var searchActive : Bool = false
    
    // reload data in table
    override func viewDidAppear(animated: Bool) {
        
        /* get selected date */
        let date : NSDate = dateSelected != nil ? (dateSelected?.convertedDate())! : NSDate()
        
        /* parse date to proper format */
        let sd = stringFromDate(date).componentsSeparatedByString(" ")
        let sdTime = sd[0] + " 00:01"
        let edTime = sd[0] + " 23:59"
        
        /* get data from server */
        let post:NSString = "title=&detail=&starttime=\(sdTime)&endtime=\(edTime)"
        NSLog("PostData: %@",post);
        let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        let postLength:NSString = String( postData.length )
        
        let url:NSURL = NSURL(string: eventByDateURL)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "post"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(accountToken, forHTTPHeaderField: "x-access-token")
        
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
            
            if(res == nil){
                NSLog("No Response!");
            }
            
            let responseData:NSString = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
            
            NSLog("Response ==> %@", responseData);
            
            var error: NSError?
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(urlData!, options: []) as? NSDictionary {
                    
                    let success:NSString = jsonResult.valueForKey("message") as! NSString
                    
                    if (success != "OK! Events list followed") {
                        NSLog("Get Event Failed")
                        let myAlert = UIAlertController(title: "Access Failed!", message: "Please Log In Again! ", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                            myAlert .dismissViewControllerAnimated(true, completion: nil)
                            self.performSegueWithIdentifier("eventTableToLogin", sender: self)
                        }))
                        presentViewController(myAlert, animated: true, completion: nil)
                        
                    } else {
                        resArray = jsonResult.valueForKey("Events") as! [NSDictionary]
                    }
                }
            } catch {
                print(error)
            }
            
        } else {
            let myAlert = UIAlertController(title: "Connection failed!", message: "urlData Equals to NULL!", preferredStyle: UIAlertControllerStyle.Alert)
            
            if let error = reponseError {
                myAlert.message = (error.localizedDescription)
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated:true, completion:nil)
        }
        
        self.tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        EventList.delegate = self
        EventList.dataSource = self
        EventList.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    // Sine:
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("SearchText: \(searchText)")
        
        var eventString : [String] = []
        for event in resArray {
            eventString.append(event.valueForKey("title") as! String)
        }
        
        searchResults = eventString.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        /*if (searchResults.count == 0){
            print("Match Search count = \(searchResults.count)")
            searchActive = false;
        } else {
            searchActive = true;
        }*/
        searchActive = true;
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of events
        print("search activate: \(searchActive)")
        if(searchActive) {
            print("Search count = \(searchResults.count)")
            return searchResults.count
        }
        return resArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        var event : NSDictionary
        print("search activate: \(searchActive)")
        // Configure the cell...
        if(searchActive){
            cell.textLabel?.text = searchResults[indexPath.row]
        } else {
            event = resArray[indexPath.row] as NSDictionary
            cell.textLabel?.text = event.valueForKey("title") as? String;
        }
        print("Cell Title: \(cell.textLabel?.text)")
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "showEventDetail") {
            let vc = segue?.destinationViewController as! EventDetailVC
            let indexPath = tableView.indexPathForSelectedRow
            if let index = indexPath {
                let event : NSDictionary = resArray[index.row]
                let id = event.valueForKey("_id") as? NSString
                let title = event.valueForKey("title") as? NSString
                let detail = event.valueForKey("detail") as? NSString
                let st = event.valueForKey("starttime") as! NSString
                let et = event.valueForKey("endtime") as! NSString
                let share = event.valueForKey("share") as? Bool
                let startTime = st.substringToIndex(st.rangeOfString(".").location - 3).stringByReplacingOccurrencesOfString("T", withString: " ")
                let endTime = et.substringToIndex(et.rangeOfString(".").location - 3).stringByReplacingOccurrencesOfString("T", withString: " ")
                NSLog("detail ==> %@", detail!);
                NSLog("st ==> %@", st);
                NSLog("et ==> %@", et);
                vc.eventDetail = EventModel(title: title!, detail: detail!, startTime: dateFromString(startTime), endTime: dateFromString(endTime), id: id!, share: share!)
            }
        }
    }
    
    func dateFromString (str : String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.dateFromString(str)
        return date!
    }
    
    func stringFromDate (date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let strDate = dateFormatter.stringFromDate(date)
        return strDate
    }
}

// Local Data
// var events:NSMutableArray = NSMutableArray()
/*
var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

var eventFromDefaults:NSMutableArray? = userDefaults.objectForKey("eventList") as? NSMutableArray

if ((eventFromDefaults) != nil) {
events = eventFromDefaults!
}
*/
// var event:NSDictionary = events.objectAtIndex(indexPath.row) as! NSDictionary