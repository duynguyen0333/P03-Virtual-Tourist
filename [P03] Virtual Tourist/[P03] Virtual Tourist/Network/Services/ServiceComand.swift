//
//  ServiceComand.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

class ServiceComand {
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("Response Image \(data)")
            handleResponse(data: data, error: error,  responseType: responseType, completionHandler: completionHandler)
        }
        task.resume()
        return task
    }
    
    private class func handleResponse<ResponseType: Decodable>(data: Data?, error: Error?, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        let completionHandler = {(response: ResponseType?, error: Error?) in
            DispatchQueue.main.async {
                completionHandler(response, error)
            }
        }
        
        guard let data = data else {
            completionHandler(nil, error)
            return
        }
        
        do {
            let response = try JSONDecoder().decode(ResponseType.self, from: data)
            debugPrint("Response \(response)")
            completionHandler(response, nil)
        } catch {
            debugPrint("Error \(error)")
            handleError(data: data, completionHandler: completionHandler)
        }
    }

    private class func handleError<ResponseType: Decodable>(data: Data, completionHandler: (ResponseType?, Error?) -> ()) {
        do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            completionHandler(nil, errorResponse)
        }catch {
            completionHandler(nil, error)
        }
    }

}
