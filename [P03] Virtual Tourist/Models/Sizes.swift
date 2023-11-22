//
//  PhotoSizes.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

struct PhotoSizes:Codable {
    let stat: String
    let sizes: Sizes
}

struct Sizes:Codable {
    let canblog: Int
    let canprint: Int
    let candownload: Int
    let size: [PhotoSizes]
}
