
import Foundation

//a specific name for getGallery completion
typealias CompletionBlock<T> = (Result<T>) -> Void

//a specific name for downloadImage completion
typealias DownloadImageCompletionBlock<T> = (Result<T>) -> Void

class NetworkManager {
    // call kiliaro api to fetch the test album result
    class func getGallery<T : Decodable>(url : URL , completionHandler : @escaping CompletionBlock<T>) {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        
        let session = URLSession(configuration: .default)
        
        var request = URLRequest(url : url)
        request.cachePolicy = .reloadIgnoringCacheData
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                let error = ApiError(code: "\(error._code)", description: error.localizedDescription)
                completionHandler(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode), let data = data {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completionHandler(.success(result))
                }catch let err{
                    print(err)
                    let error = ApiError(code: "Bad Data", description: AppConstant.networkErrorMessage)
                    completionHandler(.failure(error))
                }
                
            } else {
                let error = ApiError(code: "Unknown", description: AppConstant.networkErrorMessage)
                completionHandler(.failure(error))
                return
            }
        }.resume()
    }
    // return session data task to allow the cell cancel downloading process when it is reused
    class func downloadImage (url : URL, completionHandler : @escaping DownloadImageCompletionBlock<Data>) -> URLSessionDataTask {
        let session = URLSession.shared.dataTask(with: url) {  data, _, error in
            if error == nil , let data = data {
                completionHandler(.success(data))
            } else {
                completionHandler(.failure())
            }
        }
        session.resume()
        return session
    }
}

public struct ApiError: Error {
    var code: String?
    var description : String?
}


public enum Result<T> {
    case success(T)
    case failure(ApiError? = nil)
}
