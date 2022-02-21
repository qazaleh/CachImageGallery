//
//  GalleryItem.swift
//  KiliaroCodeChallenge
//
//  Created by qazal on 2/18/22.
//

import Foundation

public struct GalleryItem :  Codable {
    let id : String?
    let user_id : String?
    let media_type : String?
    let filename : String?
    let size : Int?
    let created_at : String?
    let taken_at : String?
    let guessed_taken_at : String?
    let md5sum: String?
    let content_type: String?
    let video: String?
    let thumbnail_url: String?
    let download_url: String?
    let resx: Int?
    let resy: Int?

}
