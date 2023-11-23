//
//  TouristPhotos.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

struct TouristPhotos : Codable {
    let stat: String
    let photos: TouristPhotosObject
}

struct TouristPhotosObject: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [TouristPhoto]
}

