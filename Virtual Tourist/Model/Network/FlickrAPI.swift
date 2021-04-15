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
        case searchphotostwo(Double, Double, Int)
        
        var stringValue: String {
            switch self {
            case .searchphotos(let lat, let long): return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Auth.key)&lat=\(lat)&lon=\(long)&per_page=12&format=json&nojsoncallback=1"
            case .searchphotostwo(let lat, let long,let pages): return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Auth.key)&lat=\(lat)&lon=\(long)&per_page=\(pages)&format=json&nojsoncallback=1"
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
    class func getPhotosIdTwo(lat: Double , long: Double ,newCollection: Bool , completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.searchphotos(lat, long).url)
        if newCollection {
            let pages = Int.random(in: 1...35)
            request = URLRequest(url: Endpoints.searchphotostwo(lat, long ,pages).url)
        }
        
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
    class func getPhoto(index: Int ,completion: @escaping (_ image: UIImage?,String?) -> Void) {
        let urls =  getPhotoURL(photoIdArray: Auth.photosInfo)
        let urlString = "\(urls[index])"
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                completion(imageFromCache,urlString) }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let imgData = try Data(contentsOf: urls[index])
                        
                        guard let image = UIImage(data: imgData) else {
                            completion(nil,nil)
                            return
                        }
                        
                    DispatchQueue.main.async {
                        let imageToCahce = image
                        imageCache.setObject(imageToCahce, forKey: urlString as AnyObject)
                       completion(imageToCahce, urlString)
                    }
                    } catch {
                        print(error)
                    }
            }
            
        }
        }
    class func getPhotoss(index: Int ,completion: @escaping (_ imageData: Data?) -> Void) {
        let urls =  getPhotoURL(photoIdArray: Auth.photosInfo)
            DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let imgData = try Data(contentsOf: urls[index])
                        
                    DispatchQueue.main.async {
                       completion(imgData)
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
