//
//  Helper.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 27/11/2023.
//

import Foundation

class Helper {
    class func sharedInstance() -> TouristService {
        struct Singleton {
            static var sharedInstance = TouristService()
        }
        return Singleton.sharedInstance
    }
}
