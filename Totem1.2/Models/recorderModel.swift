//
//  recorderModel.swift
//  Totem1.2
//
//  Created by Michael Roundcount on 10/9/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import Foundation

class recorderCharLimit {
    
    init() {}
    
    func validation(description: String?) -> Bool {
        if ((description?.count)! >= 3) {
            return true
        }else{
            return false
        }
    }
    
    //function for description validation
    func validateDescription(description:String) -> Bool {
        if (description.count) >= 3 {
            return true
        } else { return false }
    }
}
