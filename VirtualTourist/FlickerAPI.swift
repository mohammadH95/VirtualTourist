//
//  FlickerAPI.swift
//  VirtualTourist
//
//  Created by Firas Al-Amri on 21/10/1440 AH.
//  Copyright © 1440 Mohammed. All rights reserved.
//

import Foundation
import MapKit

class FlickerAPI {
    
    static let apiKey = "b5342bbfb46f49f9775fefdb08d162ae"
    static var pageNumber = 1
    static let bboxHalfWidth = 1.0
    static let bboxHalfHeight = 1.0
    static var coordinates: CLLocationCoordinate2D!
    
    enum Endpoints {
        static let basePath = "https://api.flickr.com/services/rest"
        static let apiKeyParam = "?api_key=\(FlickerAPI.apiKey)"
        static let Method = "&method"
        static let Extras = "&extras"
        static let Format = "&format"
        static let NoJSONCallback = "&nojsoncallback"
        static let SafeSearch = "&safe_search"
        static let BoundingBox = "&bbox"
        static let Page = "&page"
        static let PerPage = "&per_page"
        
        case getPhoto
        
        var stringValue: String {
            switch self {
            case .getPhoto: return Endpoints.basePath + Endpoints.apiKeyParam + Endpoints.Method + "=flickr.photos.search" + Endpoints.Extras + "=url_m" + Endpoints.Format + "=json" + Endpoints.NoJSONCallback + "=1" + Endpoints.SafeSearch + "=1" + Endpoints.Page + "=\(FlickerAPI.pageNumber)" + Endpoints.PerPage + "=\(6)" + Endpoints.BoundingBox + bboxString(for: coordinates)
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    static func bboxString(for coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let minimumLon = max(longitude - FlickerAPI.bboxHalfWidth, -180)
        let minimumLat = max(latitude - FlickerAPI.bboxHalfHeight, -90)
        let maximumLon = min(longitude + FlickerAPI.bboxHalfWidth, 180)
        let maximumLat = min(latitude + FlickerAPI.bboxHalfHeight, 90)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    class func getPhoto(coordinate: CLLocationCoordinate2D, pageNumber: Int, completion: @escaping ([URL]?, Error?) -> ()) {
        coordinates = coordinate
        let task = URLSession.shared.dataTask(with: Endpoints.getPhoto.url) { (data, response, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                completion(nil, error)
                return
            }
            
            guard let stat = result["stat"] as? String, stat == "ok" else {
                completion(nil, error)
                return
            }
            
            guard let photosDictionary = result["photos"] as? [String:Any] else {
                completion(nil, error)
                return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [[String:Any]] else {
                completion(nil, error)
                return
            }
            
            let photosURLs = photosArray.compactMap { photoDictionary -> URL? in
                guard let url = photoDictionary["url_m"] as? String else { return nil}
                return URL(string: url)
            }
            
            completion(photosURLs, nil)
        }
        task.resume()
    }
    
}
