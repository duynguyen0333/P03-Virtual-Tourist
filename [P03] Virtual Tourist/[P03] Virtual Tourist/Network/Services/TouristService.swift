//
//  TouristService.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

class TouristService {
    static let base = "https://www.flickr.com/services/rest/?api_key=\(TouristService.Constants.apiKey)&&format=json&nojsoncallback=1&"

    enum Endpoint {
        case search(String)
        case getSizes(String)
        
        var stringValue: String {
            switch self {
            case .search(let params): return TouristService.base + "method=flickr.photos.search&per_page=\(TouristService.Constants.photosPerPage)&" + params
            case .getSizes(let params): return TouristService.base + "method=flickr.photos.getSizes&" + params
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getPhotos(lat: Double, lon: Double, page: Int, completionHandler: @escaping (TouristPhotos?, Error?) -> Void) {
        let params =  "lat=\(lat)&lon=\(lon)&page=\(page)"
        
        ServiceComand.taskForGetRequest(url: TouristService.Endpoint.search(params).url, responseType: TouristPhotos.self ) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func getSizes(photoId: String, completionHandler: @escaping (Sizes?, Error?) -> Void) {
        let params =  "photo_id=\(photoId)"
        
        ServiceComand.taskForGetRequest(url: TouristService.Endpoint.getSizes(params).url, responseType: Sizes.self ) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func downloadImage(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let download = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        download.resume()
    }

    
}
