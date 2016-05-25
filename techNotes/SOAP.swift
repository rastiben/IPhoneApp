//
//  SOAP.swift
//  techNotes
//
//  Created by lionel_t on 10/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import Foundation

class SOAP{
    
    class func addNote(note:String,date:String,idClient:String,idTech:String,important:Bool,photo:String) -> NSMutableURLRequest{
        
        var is_SoapMessage: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\"><soap12:Body><addNote xmlns=\"http://tempuri.org/\"><note>\(note)</note><date>\(date)</date><idClient>\(idClient)</idClient><idTech>\(idTech)</idTech><important>\(important)</important><photo>\(photo)</photo></addNote></soap12:Body></soap12:Envelope>"
        
        
        var lobj_Request = createRequest(is_SoapMessage)
        lobj_Request.addValue("http://tempuri.org/addNote", forHTTPHeaderField: "SOAPAction")
        
        return lobj_Request
    }
    
    class func uploadPhoto(base64:String) -> NSMutableURLRequest{
        
        var is_SoapMessage: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><uploadPhoto xmlns=\"http://tempuri.org/\"><image>\(base64)</image></uploadPhoto></soap:Body></soap:Envelope>"
        
        var lobj_Request = createRequest(is_SoapMessage)
        lobj_Request.addValue("http://tempuri.org/uploadPhoto", forHTTPHeaderField: "SOAPAction")
        
        return lobj_Request
    }
    
    class func getAllNotes() -> NSMutableURLRequest{
        
        var is_SoapMessage: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><getAllNote xmlns=\"http://tempuri.org/\" /></soap:Body></soap:Envelope>"
        

        var lobj_Request = createRequest(is_SoapMessage)
        lobj_Request.addValue("http://tempuri.org/getAllNote", forHTTPHeaderField: "SOAPAction")
        
        return lobj_Request
    }
    
    class func getCustomers() -> NSMutableURLRequest{
        
        var is_SoapMessage: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><Customers xmlns=\"http://tempuri.org/\" /></soap:Body></soap:Envelope>"
        
        
        var lobj_Request = createRequest(is_SoapMessage)
        lobj_Request.addValue("http://tempuri.org/Customers", forHTTPHeaderField: "SOAPAction")
        
        return lobj_Request
    }
    
    class func getPicture(idPhoto:String) -> NSMutableURLRequest{
        
        var is_SoapMessage: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><getPicture xmlns=\"http://tempuri.org/\"><id>\(idPhoto)</id></getPicture></soap:Body></soap:Envelope>"
        

        var lobj_Request = createRequest(is_SoapMessage)
        lobj_Request.addValue("http://tempuri.org/getPicture", forHTTPHeaderField: "SOAPAction")
        
        return lobj_Request
    }
    
    class func getTech() -> NSMutableURLRequest{
        
        var is_SoapMessage: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>getTech xmlns=\"http://tempuri.org/\" /></soap:Body></soap:Envelope>"
        
        
        var lobj_Request = createRequest(is_SoapMessage)
        lobj_Request.addValue("http://tempuri.org/getTech", forHTTPHeaderField: "SOAPAction")
        
        return lobj_Request
    }
    
    class func removeNote(idNote:String) -> NSMutableURLRequest{
        
        var is_SoapMessage: String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><removeNote xmlns=\"http://tempuri.org/\"><id>\(idNote)</id></removeNote></soap:Body></soap:Envelope>"
        
        
        var lobj_Request = createRequest(is_SoapMessage)
        lobj_Request.addValue("http://tempuri.org/removeNote", forHTTPHeaderField: "SOAPAction")
        
        return lobj_Request
    }
    
    private class func createRequest(is_SoapMessage:String) -> NSMutableURLRequest{
        var is_URL: String = "https://192.168.0.66/NotesService.asmx"
        
        var lobj_Request = NSMutableURLRequest(URL: NSURL(string: is_URL)!)
        
        lobj_Request.HTTPMethod = "POST"
        lobj_Request.HTTPBody = is_SoapMessage.dataUsingEncoding(NSUTF8StringEncoding)
        lobj_Request.addValue("www.cgsapi.com", forHTTPHeaderField: "Host")
        lobj_Request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        lobj_Request.addValue(String(is_SoapMessage.characters.count), forHTTPHeaderField: "Content-Length")
        
        return lobj_Request
    }
    
}