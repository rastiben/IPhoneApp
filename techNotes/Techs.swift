//
//  Techs.swift
//  techNotes
//
//  Created by Toni SILVA DA COSTA on 24/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import Foundation

class Tech{
    
    var id: Int
    var Tech: String
    
    init( id: Int , Tech:String){
        
        self.id = id
        self.Tech = Tech
    }

    func getTech() -> String{
        return self.Tech
    }
    
    func getid() -> Int{
        return self.id
    }
    
}