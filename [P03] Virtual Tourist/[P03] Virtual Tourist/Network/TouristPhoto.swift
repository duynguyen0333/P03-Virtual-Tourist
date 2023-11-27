//
//  Photo.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

struct TouristPhoto : Codable {
    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let title: String?
    let farm: Int?
    let ispublic: Int?
    let isfriend: Int?
    let isfamily: Int?
}
