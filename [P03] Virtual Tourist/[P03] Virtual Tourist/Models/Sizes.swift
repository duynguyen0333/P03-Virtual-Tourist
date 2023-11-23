//
//  PhotoSizes.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation

struct Sizes:Codable {
    let stat: String
    let sizes: SizesObject
}

struct SizesObject:Codable {
    let canblog: Int
    let canprint: Int
    let candownload: Int
    let size: [Size]
}
