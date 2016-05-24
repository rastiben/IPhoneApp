//
//  NoteViewController.swift
//  techNotes
//
//  Created by lionel_t on 10/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import UIKit
import QuartzCore

class NoteViewController: UIViewController,NSURLSessionDelegate{
    
    var note:Note?
    
    @IBOutlet var view1: UIView!
    @IBOutlet weak var ClientLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var NoteLabel: UITextView!
    @IBOutlet weak var TechLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet var scrollview: UIScrollView!
    @IBOutlet weak var importantSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollview.contentSize.height = 3000
        self.navigationController?.toolbarHidden = true
        NoteLabel.layer.borderColor = UIColor.grayColor().CGColor
        NoteLabel.layer.borderWidth = 1.5
        NoteLabel.layer.cornerRadius = 15
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        ClientLabel.text = note!.getClient()
        picture.contentMode = UIViewContentMode.ScaleAspectFit

        
        //DATE
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh-mm-ss"
        let date = dateFormatter.dateFromString(note!.getDate())
        
        let displayDate = NSDateFormatter()
        displayDate.dateFormat = "MMM dd"
        DateLabel.text = displayDate.stringFromDate(date!)
            
        NoteLabel.text = note!.getNote()
        TechLabel.text = note!.getTech()
        importantSwitch.on = note!.getImportant()
        
        if(note?.idPhoto != "0"){
            
            var lobj_Request: NSMutableURLRequest = SOAP.getPicture(note!.idPhoto);
            
            var configuration =
                NSURLSessionConfiguration.defaultSessionConfiguration()
            var session = NSURLSession(configuration: configuration,
                                       delegate: self,
                                       delegateQueue:NSOperationQueue.mainQueue())
        
            var task = session.dataTaskWithRequest(lobj_Request, completionHandler: {data, response, error -> Void in
            
                var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
                let xml = SWXMLHash.parse(data!);
                
                var base64:String = (xml["soap:Envelope"]["soap:Body"]["getPictureResponse"]["getPictureResult"].element?.text)!
                
                let imageData = NSData(base64EncodedString: base64, options: [])
                
                self.picture.image = UIImage(data: imageData!)
                
            })
            task.resume()
            
        }
    }
    
    /*CALLBACK*/
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}