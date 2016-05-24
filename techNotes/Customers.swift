//
//  Customers.swift
//  techNotes
//
//  Created by Toni SILVA DA COSTA on 24/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import Foundation

class Customer{
    
    var id: Int
    var Client: String
    
    init( id: Int , Client: String){
        
        self.id = id
        self.Client = Client
    }

    func getClient() -> String{
        return self.Client
    }
    
    func getid() -> Int{
        return self.id
    }
}