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
    
    class func getPhotosId(lat: Double , long: Double, completion: @escaping (Bool, Error?) -> Void) {
        let request = URLRequest(url: Endpoints.searchphotos(lat, long).url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else{
                DispatchQueue.main.async {
                completion(false, error)
                }
                return
        }
            do {
                let responseObject = try JSONDecoder().decode(PhotosResponse.self, from: data)
                Auth.photosInfo = responseObject.photos.photo
                DispatchQueue.main.async {
                completion(true, nil)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                completion(false, error)
                }
            }
        }
        task.resume()
    }
    class func getPhoto(index: IndexPath ,completion: @escaping (_ image: UIImage?) -> Void) {
        let urls =  getPhotoURL(photoIdArray: Auth.photosInfo)
            DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let imgData = try Data(contentsOf: urls[index.item])
                        guard let image = UIImage(data: imgData) else {
                            completion(nil)
                            return
                        }
                    DispatchQueue.main.async {
                       completion(image)
                    }
                    } catch {
                        print(error)
                    }
            }
        }

    
   class func getPhotoURL(photoIdArray: [Photo]) -> [URL] {
        var urls = [URL]()
        for photo in photoIdArray {
            urls.append(URL(string: "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")!)
        }
        return urls
    }
    
}
