
import Foundation
import UIKit

//privide a specific name for function's completion
typealias ImageDownloadCompletionBlock = (UIImage?, Bool) -> Void

public class ImageDownloader {
    
    class func downloadImage(_ url: URL,_ cacheable: Bool , _ completionHandler: @escaping ImageDownloadCompletionBlock)-> URLSessionDataTask? {
        
        let cahceManager = CacheManager()
        
        guard let fileName = url.fileName() else {return nil}
        if cacheable {
            if let cacheImage = cahceManager.retrieve(fileName: fileName) {
                completionHandler(UIImage(data: cacheImage) , true)
                return nil
            }
        }
        let session = NetworkManager.downloadImage(url: url, completionHandler: { result in
            switch result {
            case .success(let data):
                if cacheable {
                    cahceManager.save(data: data, fileName: fileName)
                }
                completionHandler(UIImage(data: data),true)
            case .failure(_):
                completionHandler(nil, false)
            }
            
        })
        return session
    }
}
