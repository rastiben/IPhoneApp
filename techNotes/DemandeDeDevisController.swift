//
//  DemandeDeDevisController.swift
//  techNotes
//
//  Created by Toni SILVA DA COSTA on 02/06/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import UIKit
import MessageUI

class DemandeDeDevisController: UIViewController,MFMailComposeViewControllerDelegate,UITextFieldDelegate {
    

    @IBOutlet weak var nomClient: UITextField!
    @IBOutlet weak var prenomContact: UITextField!
    @IBOutlet weak var nomContact: UITextField!
    @IBOutlet weak var nomDemandeur: UITextField!
    @IBOutlet weak var objet: UITextView!
    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var mailContact: UITextField!
    @IBOutlet weak var telContact: UITextField!
    @IBOutlet weak var urgence: UISwitch!
    @IBOutlet weak var echeance: UITextField!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        objet.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.3).CGColor
        objet.layer.borderWidth = 1.0
        objet.layer.cornerRadius = 5
        objet.clipsToBounds = true
        
        
        details.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.3).CGColor
        details.layer.borderWidth = 1.0
        details.layer.cornerRadius = 5
        details.clipsToBounds = true
        
        echeance.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func sendDevis(sender: AnyObject) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["brastier@viennedoc.com"])
        mailComposerVC.setSubject("Demande de devis")
        mailComposerVC.setMessageBody("<p><b>Nom du client : </b>\(nomClient.text!)</p></br><p><b>Nom du Demandeur : </b>\(nomDemandeur.text!)</p></br><p><b>Personne à contacter : </b></p></br><p><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nom : </b>\(nomContact.text!)</p></br><p><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Prenom : </b>\(prenomContact.text!)</p></br><p><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Téléphone : </b>\(telContact.text!)</p></br><p><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Mail : </b>\(mailContact.text!)</p></br><p><b>Objet de la demande : </b>\(objet.text)</p></br><p><b>Détails de la demande : </b>\(details.text)</p></br><p><b>Echéance : </b>\(echeance.text!)</p></br><p><b>Urgent : </b>\((urgence.on ? "Oui" : "Non"))</p></br>", isHTML: true)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert(){
        let sendMailErrorAlert = UIAlertView(title: "Impossible d'envoyez le mail", message: "Vérifier la configuration des mails", delegate: self, cancelButtonTitle: "OK")
        
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
