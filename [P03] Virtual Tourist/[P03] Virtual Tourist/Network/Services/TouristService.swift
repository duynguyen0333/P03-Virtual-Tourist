//
//  TouristService.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation
import MapKit
import UIKit

class TouristService {
//    static let base = "https://www.flickr.com/services/rest/?api_key=\(TouristService.Constants.apiKey)&&format=json&nojsoncallback=1&"
//
//    enum Endpoint {
//        case search(String)
//        case getSizes(String)
//        
//        var stringValue: String {
//            switch self {
//            case .search(let params): return TouristService.base + "method=flickr.photos.search&per_page=\(TouristService.Constants.photosPerPage)&" + params
//            case .getSizes(let params): return TouristService.base + "method=flickr.photos.getSizes&" + params
//            }
//        }
//        
//        var url: URL {
//            return URL(string: stringValue)!
//        }
//    }
//    
//    class func getPhotos(lat: Double, lon: Double, page: Int, completionHandler: @escaping (TouristPhotos?, Error?) -> Void) {
//        let params =  "lat=\(lat)&lon=\(lon)&page=\(page)"
//        
//        ServiceComand.taskForGetRequest(url: TouristService.Endpoint.search(params).url, responseType: TouristPhotos.self ) { response, error in
//            if let response = response {        
//                completionHandler(response, nil)
//            } else {
//                completionHandler(nil, error)
//            }
//        }
//    }
//                
//    class func getSizes(photoId: String, completionHandler: @escaping (Sizes?, Error?) -> Void) {
//        let params =  "photo_id=\(photoId)"
//        
//        ServiceComand.taskForGetRequest(url: TouristService.Endpoint.getSizes(params).url, responseType: Sizes.self ) { response, error in
//            if let response = response {
//                
//                completionHandler(response, nil)
//            } else {
//                completionHandler(nil, error)
//            }
//        }
//    }
//    
//    class func downloadImage(url: URL, completion: @escaping (Data?, Error?) -> Void) {
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                print("Error loading image: \(error.localizedDescription)")
//                completion(nil, error)
//                return
//            }
//            
//            guard let data = data else {
//                DispatchQueue.main.async {
//                    completion(nil, error)
//                }
//                return
//            }
//            
//            DispatchQueue.main.async {
//                print("Dowloaded \(data)")
//                completion(data, nil)
//            }
//        }
//        task.resume()
//    }
    
    func getSearchPhotos(_ coordinate:  CLLocationCoordinate2D, completionHandler: @escaping (_ result: [[String:Any]], _ error: Error?) -> Void) -> URLSessionDataTask {
        var parameters = buildParameters(coordinate: coordinate)
        let url = URLRequest(url: buildUrlComponent(parameters: parameters))
        var parseData:[String:AnyObject]!

        let task = URLSession.shared.dataTask(with: url) { (data , response, error) in
            
            
            guard (error == nil) else {
                completionHandler([[:]], error)
                return
            }
    
            guard let data = data else {
                completionHandler([[:]], error)
                return
            }

            do {
                parseData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                completionHandler([[:]], error)


            }
            
            guard let stat = parseData[TouristService.ResponseKeys.Status] as? String, stat == TouristService.ResponseValues.OK else {
                completionHandler([[:]], error)
                return
            }
            
            guard let photos = parseData[TouristService.ResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandler([[:]], error)
                return
            }
            
            guard let pages = photos[TouristService.ResponseKeys.Pages] as? Int else {
                completionHandler([[:]], error)
                return
            }
            
            let pageLimit = min(pages , 20)
            let random = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            let _ = self.displayPhoto(parameters, pageNumber: random, completionHandler: {(results, error) in
                completionHandler(results, error)
            })
            
        }
        task.resume()
        return task
    }
    
    private func displayPhoto(_ parameters: [String: AnyObject], pageNumber: Int, completionHandler: @escaping (_ result: [[String:Any]], _ error: Error?) -> Void) -> URLSessionDataTask {
        var parameterWithPage = parameters
        parameterWithPage[TouristService.ParametersKeys.Page] = pageNumber as AnyObject?
        
        let url = URLRequest(url: buildUrlComponent(parameters: parameterWithPage))
        var parseData:[String:AnyObject]!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandler([[:]], error)
                return
            }
            
            guard let data = data else {
                completionHandler([[:]], error)
                return
            }
            
            do {
                parseData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {

                completionHandler([[:]], error)
                return
            }
            
            guard let stat = parseData[TouristService.ResponseKeys.Status] as? String, stat == TouristService.ResponseValues.OK else {
                completionHandler([[:]], error)
                return
            }
            
            guard let photos = parseData[TouristService.ResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandler([[:]], error)
                return
            }
            
            guard let photosArray = photos[TouristService.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                completionHandler([[:]], error)
                return
            }
            print("PHoto array \(photosArray)")
            
            completionHandler(photosArray, nil)
            
        }
        task.resume()
        return task
    }

    private func buildUrlComponent(parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = TouristService.Constants.APIScheme
        components.host  = TouristService.Constants.APIHost
        components.path = TouristService.Constants.APIPath
        components.queryItems = [URLQueryItem]()

        for (key,value) in parameters {
            let item = URLQueryItem(name: key, value: "\(value )")
            components.queryItems!.append(item)
        }
        
        return components.url!
    }
    
    private func buildParameters(coordinate: CLLocationCoordinate2D) -> [String: AnyObject] {
        let parameters = [
            TouristService.ParametersKeys.Lat: coordinate.latitude,
            TouristService.ParametersKeys.Lon: coordinate.longitude,
            TouristService.ParametersKeys.Method: TouristService.ParametersValues.SearchMethod,
            TouristService.ParametersKeys.APIKey: TouristService.ParametersValues.apiKey,
            TouristService.ParametersKeys.SafeSearch: TouristService.ParametersValues.UseSafeSearch,
            TouristService.ParametersKeys.Extras: TouristService.ParametersValues.MediumURL,
            TouristService.ParametersKeys.Format: TouristService.ParametersValues.ResponseFormat,
            TouristService.ParametersKeys.PerPage: TouristService.ParametersValues.PerPageValue,
            TouristService.ParametersKeys.NoJSONCallback: TouristService.ParametersValues.DisableJSONCallback
        ] as [String: AnyObject]
        
        return parameters
    }
    
    class func sharedInstance() -> TouristService {
        struct Singleton {
            static var sharedInstance = TouristService()
        }
        return Singleton.sharedInstance
    }
    
}
