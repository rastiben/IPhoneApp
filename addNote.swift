//
//  addNote.swift
//  techNotes
//
//  Created by Toni SILVA DA COSTA on 23/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import UIKit
import QuartzCore

class addNote: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate{

    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var NoteLabel: UITextView!
    
    @IBOutlet weak var Client: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Technicien: UILabel!
    @IBOutlet weak var Important: UISwitch!
    
    var clientChoose:Customer!
    var listTech:[Tech] = []
    var alertController:UIAlertController!
    var dateNow:NSDate!
    var techChoose:Tech!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*INIT*/
        navigationController?.delegate = self
        
        NoteLabel.layer.borderColor = UIColor.grayColor().CGColor
        NoteLabel.layer.borderWidth = 1.5
        NoteLabel.layer.cornerRadius = 15
        
        dateNow = NSDate()

        var displayDate = NSDateFormatter()
        displayDate.dateFormat = "MMM dd"
        Date.text = displayDate.stringFromDate(dateNow)

        image.contentMode = UIViewContentMode.ScaleAspectFit
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func chooseTech(sender: AnyObject) {
        
        if listTech.count == 0 {
        //PREPARE DIALOG//
        let controller = UIViewController()
        var alertTableView = UITableView()

        //GETTECH//
        var lobj_Request: NSMutableURLRequest = SOAP.getTech();
            
        var configuration =
                NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration,
                                       delegate: self,
                                       delegateQueue:NSOperationQueue.mainQueue())
            
        var task = session.dataTaskWithRequest(lobj_Request, completionHandler: {data, response, error -> Void in
            
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            let xml = SWXMLHash.parse(data!);
            
            var count:Int = 1
            for elem in xml["soap:Envelope"]["soap:Body"]["getTechResponse"]["getTechResult"]["anyType"] {
                
                var str:String = (elem.element?.text)!
                //id note client date
                
                self.listTech.append(Tech(id: count,Tech: str))
                
                count += 1
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //START DIALOG//
                var rect:CGRect?
                if (self.listTech.count < 2) {
                    rect = CGRectMake(0, 0, 272, 100)
                    controller.preferredContentSize = rect!.size
                    
                }
                else if (self.listTech.count < 4){
                    rect = CGRectMake(0, 0, 272, 150);
                    controller.preferredContentSize = rect!.size
                }
                else if (self.listTech.count < 6){
                    rect = CGRectMake(0, 0, 272, 200);
                    controller.preferredContentSize = rect!.size
                    
                }
                else{
                    rect = CGRectMake(0, 0, 272, 350);
                    controller.preferredContentSize = rect!.size
                }
                alertTableView  = UITableView(frame: rect!)
                alertTableView.delegate = self
                alertTableView.dataSource = self
                alertTableView.tableFooterView = UIView(frame: CGRectZero)
                alertTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                let nib = UINib(nibName: "LabelCell", bundle: nil)
                alertTableView.registerNib(nib, forCellReuseIdentifier: "LabelCell")
                
                //alertTableView?.tag = kAlert
                controller.view.addSubview(alertTableView)
                controller.view.bringSubviewToFront(alertTableView)
                controller.view.userInteractionEnabled = true
                alertTableView.userInteractionEnabled = true
                alertTableView.allowsSelection = true
                self.alertController = UIAlertController(title: "Technicien", message: "", preferredStyle: .Alert)
                self.alertController.setValue(controller, forKey: "contentViewController")
                let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                self.alertController.addAction(cancelAction)
                
                
                self.presentViewController(self.alertController, animated: true, completion: nil)
                alertTableView.reloadData()
            })
            
            
            if error != nil
            {
                print("Error: " + error!.description)
            }
            
            
        })
        task.resume()
        } else {
            self.presentViewController(self.alertController, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func SaveNote(sender: AnyObject) {
        if clientChoose != nil &&
            NoteLabel.text != nil &&
            techChoose != nil {
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy hh-mm-ss"
            
            var lobj_Request: NSMutableURLRequest = SOAP.addNote(NoteLabel.text,date: dateFormatter.stringFromDate(dateNow) , idClient: String(clientChoose.getid()), idTech: String(techChoose.getid()), important: Important.on,photo: "");
            
            var configuration =
                NSURLSessionConfiguration.defaultSessionConfiguration()
            var session = NSURLSession(configuration: configuration,
                                       delegate: self,
                                       delegateQueue:NSOperationQueue.mainQueue())
            
            var task = session.dataTaskWithRequest(lobj_Request, completionHandler: {data, response, error -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
            })
            task.resume()
            
        } else {
            
            var alert = UIAlertController(title: "Erreur", message: "Tout les champs ne sont pas renseigné", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    /*CALLBACK*/
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTech.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style:UITableViewCellStyle.Default,reuseIdentifier:"LabelCell")
        
        cell.textLabel?.text = listTech[indexPath.row].getTech()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        self.Technicien.text = cell?.textLabel?.text
        
        techChoose = listTech[indexPath.row]
        
        alertController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        Client.text = clientChoose != nil ? clientChoose.getClient() : "Client"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        imagePicker = UIImagePickerController()
        imagePicker!.delegate = self
        imagePicker!.sourceType = .Camera
            
        presentViewController(imagePicker!,animated: true,completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker!.dismissViewControllerAnimated(true, completion: nil)
        image.image = info[UIImagePickerControllerOriginalImage] as? UIImage
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