//
//  clientController.swift
//  techNotes
//
//  Created by Toni SILVA DA COSTA on 23/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import UIKit

class clientController: UITableViewController, UINavigationControllerDelegate ,NSURLSessionDelegate{

    var Clients:[Customer] = []
    var FilteredClients:[Customer] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    var clientSelected:Customer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        //LOADING
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        tableView.backgroundView = activityIndicatorView
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        activityIndicatorView.startAnimating()
        
        //GET NOTE
        var lobj_Request: NSMutableURLRequest = SOAP.getCustomers();
        
        var configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration,
                                   delegate: self,
                                   delegateQueue:NSOperationQueue.mainQueue())
        
        var task = session.dataTaskWithRequest(lobj_Request, completionHandler: {data, response, error -> Void in
            
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            let xml = SWXMLHash.parse(data!);
            ["anyType"]
            
            var count:Int = 0
            for elem in xml["soap:Envelope"]["soap:Body"]["CustomersResponse"]["CustomersResult"]["anyType"] {
                
                var str:String = (elem.element?.text)!
                var strSplit = str.componentsSeparatedByString(";")
                //id note client date
                self.Clients.append(Customer(id: Int(strSplit[0])!,Client: strSplit[1]))
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                sleep(1)
                activityIndicatorView.stopAnimating()
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                self.tableView.reloadData()
            })
            
            
            if error != nil
            {
                print("Error: " + error!.description)
            }
            
            
        })
        task.resume()
        
        //FILTER
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Rechercher un client"
        
        // Do any additional setup after loading the view.
    }

    /*CALLBACK*/
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != ""{
            return FilteredClients.count
        }
        return Clients.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath)

        if searchController.active && searchController.searchBar.text != ""{
            cell.textLabel?.text = FilteredClients[indexPath.row].getClient()
        } else  {
            cell.textLabel?.text = Clients[indexPath.row].getClient()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if searchController.active && searchController.searchBar.text != ""{
            clientSelected = FilteredClients[indexPath.row]
        } else  {
            clientSelected = Clients[indexPath.row]
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? addNote {
            controller.clientChoose = clientSelected  // Here you pass the data back to your original view controller
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //RESEARCH
    func filterContentForSearchText(searchText:String,scope:String = "All"){
        
        FilteredClients = Clients.filter{Client in
            return Client.getClient().lowercaseString.containsString("411\(searchText.lowercaseString)")
        }
        tableView.reloadData()
    }

}

extension clientController: UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController){
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
