//
//  NoteViewController.swift
//  techNotes
//
//  Created by lionel_t on 10/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import UIKit
import QuartzCore

class NoteViewController: UIViewController,NSURLSessionDelegate,NSURLSessionDataDelegate{
    
    var note:Note?
    
    @IBOutlet weak var visibleView: UIView!
    @IBOutlet var view1: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var ClientLabel: UILabel!
    @IBOutlet weak var labelPercent: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var NoteLabel: UITextView!
    @IBOutlet weak var TechLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet var scrollview: UIScrollView!
    @IBOutlet weak var importantSwitch: UISwitch!
    
    var buffer:NSMutableData = NSMutableData()
    /*var session:NSURLSession?
    var dataTask:NSURLSessionDataTask?
    let url = NSURL(string:"http://i.stack.imgur.com/b8zkg.png" )!*/
    var expectedContentLength = 0
    
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
            
            //let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            
            //activityIndicatorView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
            //var location = CGPoint(x: UIScreen.mainScreen().bounds.width / 2 ,y: picture.center.y)
            //activityIndicatorView.center = location
            
            //self.view.addSubview(activityIndicatorView)
            //self.visibleView.addSubview(activityIndicatorView)
            
            //activityIndicatorView.startAnimating()

            //tableView.backgroundView = activityIndicatorView
            
            //tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            let lobj_Request: NSMutableURLRequest = SOAP.getPicture(note!.idPhoto);
            
            let configuration =
                NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration,
                                       delegate: self,
                                       delegateQueue:NSOperationQueue.mainQueue())
            
            let task = session.dataTaskWithRequest(lobj_Request)
            task.resume()
            /*let task = session.dataTaskWithRequest(lobj_Request, completionHandler: {data, response, error -> Void in
                
                let xml = SWXMLHash.parse(data!);
                
                let base64:String = (xml["soap:Envelope"]["soap:Body"]["getPictureResponse"]["getPictureResult"].element?.text)!
                
                let imageData = NSData(base64EncodedString: base64, options: [])
                
                self.picture.image = UIImage(data: imageData!)
                
                
                //activityIndicatorView.stopAnimating()
                
            })*/

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
    
    
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        //here you can get full lenth of your content
        expectedContentLength = Int(response.expectedContentLength)
        //println(expectedContentLength)
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        
        buffer.appendData(data)
        
        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
        progressView.progress =  percentageDownloaded
        
        labelPercent.text = "\(Int(percentageDownloaded*100))%"
    }
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        //use buffer here.Download is done
        progressView.progress = 1.0   // download 100% complete
        progressView.alpha = 0
        labelPercent.alpha = 0
        
        let xml = SWXMLHash.parse(buffer);
        
        let base64:String = (xml["soap:Envelope"]["soap:Body"]["getPictureResponse"]["getPictureResult"].element?.text)!
        
        let imageData = NSData(base64EncodedString: base64, options: [])
        
        self.picture.image = UIImage(data: imageData!)

    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        
    }
    
    /*func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        
        var uploadProgress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progressView.progress.advancedBy(uploadProgress - self.progressView.progress)
             
        labelPercent.text = "\(Int(uploadProgress*100))%"

    }*/
    
    /*func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didFinishDownloadingToURL location: NSURL!){
        
    }*/
    
    
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