//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Jagdeep Singh on 02/04/21.
//

import Foundation
import UIKit

class FlickerAPI {
    
    struct Auth {
        static var key: String = "d8f8996feaa4cd3fa6a12b634097767d"
        static var lat: Double = 0.0
        static var long: Double = 0.0
        static var photosInfo = [Photo]()
    }
    
    enum Endpoints {
        case searchphotos(Double, Double)
        
        var stringValue: String {
            switch self {
            case .searchphotos(let lat, let long): return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Auth.key)&lat=\(lat)&lon=\(long)&per_page=9&format=json&nojsoncallback=1"
            }
        }
        var url: URL {
            return URL(string: stringValue)! }
    }
    
    class func searchPhotos(lat: Double , long: Double, completion: @escaping (Bool, Error?) -> Void) {
        let request = URLRequest(url: Endpoints.searchphotos(lat, long).url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else{
                completion(false,error)
                return
        }
            do {
                let responseObject = try JSONDecoder().decode(PhotosResponse.self, from: data)
                Auth.photosInfo = responseObject.photos.photo
                completion(true, nil)
            } catch {
                print(error)
            }
            
    }
        task.resume()
}

}
