//
//  TouristPhotos.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

struct Photos : Codable {
    let stat: String
    let photos: PhotosObject
}

struct PhotosObject: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [TouristPhoto]
}

