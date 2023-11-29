//
//  Constants.swift
//  VirtualTourist
//
//  Created by Sarah Alhumud on 11/06/1440 AH.
//  Copyright © 1440 Sarah Alhumud. All rights reserved.
//

import UIKit
import Foundation

extension TouristService {    
    struct Constants {
        static let APIKey = "a906419e24f345ec38e48471d4216aad"
        static let schema = "https"
        static let path = "/services/rest"
        static let host = "api.flickr.com"
    }
    
    struct ResponseKeys {
        static let Status = "stat"
        static let Pages = "pages"
        static let Total = "total"
        static let Photos = "photos"
        static let Photo = "photo"
        static let URL = "url_m"
    }
    
    struct ResponseValues {
        static let OK = "ok"
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let Format = "format"
        static let NoJsonCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Page = "page"
        static let PerPage = "per_page"
        static let Extras = "extras"
        static let APIKey = "api_key"
    }
    
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let Format = "json"
        static let DisableJsonCallback = "1"
        static let SafeSearch = "1"
        static let PerPage = "20"
        static let MediumURL = "url_m"
    }
}
