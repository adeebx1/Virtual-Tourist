//
//  FlickerAPIClient.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 09/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import SwiftyJSON

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    enum connectionStatus{
        case connected, notConnected, connctedWithError
    }
}

class FlickerAPIClient {
    struct Constants {
        static let baseURL = "https://api.flickr.com/services/rest"
        static let apiKey = "63d8dc265bcfd14ccc1290b71a6ccc1f"
        static let method = "flickr.photos.search"
        static let format = "json"
        static let tags = ""
        static let accuracy = 11
        static let perPage = 10
        static let noJSONCallback = 1
    }
    
    static func requestPhotos(lat: Double, long:Double, completionHandler: @escaping ([String]?,Connectivity.connectionStatus) -> Void){
        let photosRequest = "\(Constants.baseURL)?api_key=\(Constants.apiKey)&method=\(Constants.method)&format=json&lat=\(lat)&lon=\(long)&per_page=\(Constants.perPage)&accuracy=\(Constants.perPage)&nojsoncallback=\(Constants.noJSONCallback)&page=\((1...10).randomElement() ?? 1)"
        // Check for Network connectivity before making request
        if !Connectivity.isConnectedToInternet(){
            completionHandler(nil,.notConnected)
        }
        Alamofire.request(photosRequest).responseJSON { (response) in
            if ((response.result.value) != nil) {
                let JSONObject = JSON(response.result.value!)
                var photosURLs: [String] = []
                
                if let photos = JSONObject["photos"]["photo"].array {
                    
                    for photo in photos{
                        let photoURL = "https://farm\(photo["farm"].stringValue).staticflickr.com/\(photo["server"].stringValue)/\(photo["id"])_\(photo["secret"]).jpg"
                        photosURLs.append(photoURL)
                    }
                }
                completionHandler(photosURLs,.connected)
                
            }
            else {
                completionHandler(nil,.connctedWithError)
            }
            
        }
    }
    
}
