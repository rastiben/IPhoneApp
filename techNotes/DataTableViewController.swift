//
//  DataTableViewController.swift
//  techNotes
//
//  Created by lionel_t on 09/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import UIKit

class DataTableViewController: UITableViewController,NSURLSessionDelegate{
    
    var Notes:[Note] = []
    var FilteredNote:[Note] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //GETNOTE
        refresh(nil)
        
        //SEARCHBAR
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["Client", "Technicien"]
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Rechercher un client"
        
        //SCOPE BAR
        //searchController.searchBar.showsScopeBar = true
        //searchController.searchBar.scopeButtonTitles = ["Client","Technicien"]
        
        //REFRESHCONTROL
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(DataTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //self.tableView.addSubview(refreshControl!)
        
        
    }
    
    func refresh(sender:AnyObject?){
        
        if Reachability.isConnectedToNetwork() {
            
            Notes.removeAll()
            
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            
            tableView.backgroundView = activityIndicatorView
            
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            activityIndicatorView.startAnimating()
            
            //GET NOTE
            let request = SOAP.getAllNotes()
            let configuration =
                NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration,
                                       delegate: self,
                                       delegateQueue:NSOperationQueue.mainQueue())
            let task = session.dataTaskWithRequest(request){
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                let xml = SWXMLHash.parse(data!);
                
                for elem in xml["soap:Envelope"]["soap:Body"]["getAllNoteResponse"]["getAllNoteResult"]["anyType"].reverse() {
                    
                    let str:String = (elem.element?.text)!
                    var strSplit = str.componentsSeparatedByString(";")
                    
                    //id note client da
                    self.Notes.append(Note(id: Int(strSplit[0])!,
                        Client: strSplit[2],
                        Note: strSplit[1],
                        Date: strSplit[3],
                        Tech:strSplit[4],
                        important:self.toBool(strSplit[5])!,
                        idPhoto:strSplit[6]))
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if self.refreshControl != nil {
                        self.refreshControl?.endRefreshing()
                    }
                    
                    sleep(1)
                    activityIndicatorView.stopAnimating()
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    self.tableView.reloadData();
                })
                
                if error != nil
                {
                    print("Error: " + error!.description)
                }
            }
            task.resume()
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = false
        self.navigationItem.hidesBackButton = true
        
        if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (Notes.count < 1) {
            //create a lable size to fit the Table View
            var messageLbl:UILabel = UILabel.init(frame: CGRectMake(0, 0,
                    self.tableView.bounds.size.width,
                    self.tableView.bounds.size.height))
            //set the message
            messageLbl.text = "Aucune note";
            //center the text
            messageLbl.textAlignment = NSTextAlignment.Center;
            //auto size the text
            messageLbl.sizeToFit()
            
            //set back to label view
            self.tableView.backgroundView = messageLbl;
            //no separator
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            return 0;
        }
        
        self.tableView.backgroundView = nil
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if searchController.active && searchController.searchBar.text != ""{
            return FilteredNote.count
        }
        
        return Notes.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! TableViewCell
        
        if Notes.count > 0 {
            var temp:Note
            
            if searchController.active && searchController.searchBar.text != ""{
                temp = FilteredNote[indexPath.row]
            } else  {
                temp = Notes[indexPath.row]
            }
            
            // Configure the cell...
            cell.Client.text = temp.getClient()
            cell.Note.text = temp.getNote()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy hh-mm-ss"
            let date = dateFormatter.dateFromString(temp.getDate())
            
            let displayDate = NSDateFormatter()
            displayDate.dateFormat = "MMM dd"
            cell.Date.text = displayDate.stringFromDate(date!)
            
            //TECH
            let tech = temp.getTech()
            
            var strSplit = tech.componentsSeparatedByString(" ")
            cell.Technicien.text = "\((strSplit[0] as NSString).substringToIndex(1))\((strSplit[1] as NSString).substringToIndex(1))"
            
            let path = UIBezierPath.init(ovalInRect: CGRect(x: 2.5, y: 24.5, width: 50.0, height: 50.0))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.CGPath
            cell.ovalShape.layer.mask = maskLayer
            
            if NSUserDefaults.standardUserDefaults().colorForKey(tech) == nil {
                let color = UIColor.randomColor()
                cell.ovalShape.backgroundColor = color
                NSUserDefaults.standardUserDefaults().setColor(color, forKey: tech)
            } else {
                cell.ovalShape.backgroundColor = NSUserDefaults.standardUserDefaults().colorForKey(tech)
            }
            
            cell.Danger.hidden = !temp.getImportant()
            cell.Photo.hidden = temp.getIdPhoto() == "0" ? true:false
        }
        return cell
    }
    
    //REMOVE ROW
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //RESEARCH
    func filterContentForSearchText(searchText:String,scope:String = "All"){
        
        if scope == "Technicien"{
            FilteredNote = Notes.filter{Note in
                return Note.getTech().lowercaseString.containsString(searchText.lowercaseString)
            }
        } else {
            FilteredNote = Notes.filter{Note in
                return Note.getClient().lowercaseString.containsString("411\(searchText.lowercaseString)")
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let temp = Notes[indexPath.row]
        
        let lobj_Request: NSMutableURLRequest = SOAP.removeNote(String(temp.getid()));
        
        let configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration,
                                   delegate: self,
                                   delegateQueue:NSOperationQueue.mainQueue())
        
        let task = session.dataTaskWithRequest(lobj_Request, completionHandler: {data, response, error -> Void in
            
        })
        task.resume()
        
        Notes.removeAtIndex(indexPath.row)
        
        tableView.reloadData()
        
        self.setEditing(false, animated: false)
    }
    
    /*CALLBACK*/
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
    }
    
    
    func toBool(str:String) -> Bool? {
        switch (str) {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.editing{
            return false
        } else {
            return true
        }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueNote"
        {
            if let destination = segue.destinationViewController as? NoteViewController{
                let temp:Note
                
                if searchController.active && searchController.searchBar.text != ""{
                    temp = FilteredNote[(tableView.indexPathForSelectedRow?.row)!]
                } else  {
                    temp = Notes[(tableView.indexPathForSelectedRow?.row)!]
                }
                
                destination.note = temp
            }
        }
    }
}

extension DataTableViewController: UISearchResultsUpdating, UISearchBarDelegate{
    func updateSearchResultsForSearchController(searchController: UISearchController){
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        let r = CGFloat.random()
        let g = CGFloat.random()
        let b = CGFloat.random()
        
        // If you wanted a random alpha, just create another
        // random number for that too.
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension NSUserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = dataForKey(key) {
            color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
        }
        setObject(colorData, forKey: key)
    }
    
}
