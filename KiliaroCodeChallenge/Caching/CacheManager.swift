//
//  CacheManager.swift
//  KiliaroCodeChallenge
//
//  Created by qazal on 2/20/22.
//

import Foundation

protocol CacheProtocol {
    func save(data:Data, fileName:String)
    func retrieve(fileName:String) -> Data?
}

class CacheManager: CacheProtocol {
    //save data to temp directory using file name
    func save(data: Data, fileName: String) {
        let defaultManager = FileManager.default
        let tempURL = defaultManager.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: tempURL)
        }catch{
            return
        }
    }
    // retrieve data from cache directory using file name
    func retrieve(fileName: String) -> Data? {
        let defaultManager = FileManager.default
        let tempURL = defaultManager.temporaryDirectory.appendingPathComponent(fileName)
        if defaultManager.fileExists(atPath: tempURL.path){
            if let data = try? Data(contentsOf: tempURL) {
                return data
            }
        }
        return nil
    }
    //if there is cached data for the item clean up
    func cleanUp(list:[GalleryItem]){
        let defaultManager = FileManager.default
        
        list.forEach{ item in
            guard let thumbURL = item.thumbnail_url, let url = URL(string: thumbURL), let fileName = url.fileName() else {
                return
            }
            let tempURL = defaultManager.temporaryDirectory.appendingPathComponent(fileName)
            if defaultManager.fileExists(atPath: tempURL.path){
                do {
                    try defaultManager.removeItem(at: tempURL)
                }catch let err {
                    print(err)
                }
            }
            
        }
    }
}
