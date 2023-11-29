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
    func getPages(_ coordinate: CLLocationCoordinate2D, completionHandler: @escaping (_ result: [[String:Any]], _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let parameters = buildParameters(coordinate: coordinate)
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: buildURL(parameters))) {(data, response, error) in
            let parsedData: [String:AnyObject]!

            guard (error == nil) else {
                completionHandler([[:]], error)
                return
            }
            
            guard let data = data else {
                completionHandler([[:]], error)
                return
            }
            
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                guard let stat = parsedData[TouristService.ResponseKeys.Status] as? String, TouristService.ResponseValues.OK.contains(stat) else {
                    completionHandler([[:]], error)
                    return
                }
                
                guard let photos = parsedData[TouristService.ResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler([[:]], error)
                    return
                }
                
                guard let pages = photos[TouristService.ResponseKeys.Pages] as? Int else {
                    completionHandler([[:]], error)
                    return
                }
                
                let pageRange = min(pages, 100)
                let randomPage = Int(arc4random_uniform(UInt32(pageRange))) + 1
                self.getPhotosBySearch(parameters, pageNumber: randomPage, completionHandler: {(results, error) in
                    completionHandler(results, error)
                })
            } catch {
                completionHandler([[:]], error)
                return
            }
        }
        
        task.resume()
        return task
    }
        
        
    private func getPhotosBySearch(_ parameters: [String: AnyObject], pageNumber: Int, completionHandler: @escaping (_ result: [[String:Any]], _ error: Error?) -> Void) -> URLSessionDataTask {
        var parametersWithPageNumber = parameters
        parametersWithPageNumber[TouristService.ParameterKeys.Page] = pageNumber as AnyObject?
        
        let url = URLRequest(url: buildURL(parametersWithPageNumber))
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            let parsedData: [String:AnyObject]!
            
            guard (error == nil) else {
                completionHandler([[:]], error)
                return
            }
            
            guard let data = data else {
                completionHandler([[:]], error)
                return
            }
            
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                guard let stat = parsedData[TouristService.ResponseKeys.Status] as? String, TouristService.ResponseValues.OK.contains(stat) else {
                    completionHandler([[:]], error)
                    return
                }
                
                guard let photosDictionary = parsedData[TouristService.ResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler([[:]], error)
                    return
                }
                
                guard let photos = photosDictionary[TouristService.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                    completionHandler([[:]], error)
                    return
                }
                completionHandler(photos, nil)
            } catch {
                completionHandler([[:]], error)
                return
            }
        }
        task.resume()
        return task
    }
    
    private func buildURL(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = TouristService.Constants.schema
        components.host = TouristService.Constants.host
        components.path = TouristService.Constants.path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let item = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(item)
        }
        
        return components.url!
    }
    
    private func buildParameters(coordinate: CLLocationCoordinate2D) -> [String:AnyObject]  {
        let methodParameters = [
            TouristService.ParameterKeys.Method: TouristService.ParameterValues.SearchMethod,
            TouristService.ParameterKeys.APIKey: TouristService.Constants.APIKey,
            TouristService.ParameterKeys.SafeSearch: TouristService.ParameterValues.SafeSearch,
            TouristService.ParameterKeys.Extras: TouristService.ParameterValues.MediumURL,
            TouristService.ParameterKeys.Format: TouristService.ParameterValues.Format,
            TouristService.ParameterKeys.NoJsonCallback: TouristService.ParameterValues.DisableJsonCallback,
            TouristService.ParameterKeys.PerPage: TouristService.ParameterValues.PerPage,
            TouristService.ParameterKeys.Latitude: coordinate.latitude,
            TouristService.ParameterKeys.Longitude: coordinate.longitude
            ] as [String:AnyObject]
        return methodParameters
    }
}
