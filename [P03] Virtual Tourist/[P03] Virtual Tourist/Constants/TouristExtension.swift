//
//  Constants.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

extension TouristService {
    struct Constants {
//        static let APIScheme = "https"
//        static let APIHost = "api.flickr.com"
//        static let APIPath = "/services/rest"
//        static let apiKey = "a906419e24f345ec38e48471d4216aad"
//        static let photosPerPage = 12
        
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"

    }
    
    struct ResponseKeys {
        static let Status = "stat"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
        static let Title = "title"
        static let Photos = "photos"
        static let Photo = "photo"
    
    }
    
    struct ResponseValues {
        static let OK = "ok"
    }
    
    struct ParametersKeys {
        static let Method = "method"
        static let Lat = "lat"
        static let Lon = "lons"
        static let Page = "page"
        static let PerPage = "per_page"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"

    }
    
    struct ParametersValues {
        static let SearchMethod = "flickr.photos.search"
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PerPageValue = "20"
        static let apiKey = "a906419e24f345ec38e48471d4216aad"
    }
    
    
    
}
