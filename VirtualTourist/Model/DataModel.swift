//
//  DataModel.swift
//  VirtualTourist
//
//  Created by sam on 2/10/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit

struct PhotoURL {
    var id = String()
    var url_m = String()
}

class PhotoLib {
    
//    var results = [PhotoURLs]()
    
    static func getPhotoURLs(lat:Double,lon:Double) -> [PhotoURL] {
        
//        var urlString = "https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=11ebab0e0173a322ca87cee9c81a349a&lat=0&lon=0&extras=url_m&format=json&nojsoncallback=1"
        
        //        let urlString = "https://api.flickr.com/services/rest?method=flickr.photos.search&format=json&bbox=2.28,48.84,2.30,48.86&api_key=11ebab0e0173a322ca87cee9c81a349a&safe_search=1&extras=url_m&nojsoncallback=1"

        //        let url = URL(string: urlString)

        
        var results = [PhotoURL]()
        let url = buildURL(lat:lat, lon:lon)
        
        results = sendReguest(url: url)
        print("#######  url is \(url)")
        return results
    }
    
    //build URL
      class func buildURL(lat:Double=0,lon:Double=0) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        let queryItem1 = URLQueryItem(name: "method", value: "flickr.photos.search")
        let queryItem2 = URLQueryItem(name: "api_key", value: "11ebab0e0173a322ca87cee9c81a349a")
        let queryItem3 = URLQueryItem(name: "lat", value: String(lat))
        let queryItem4 = URLQueryItem(name: "lon", value: String(lon))
        let queryItem5 = URLQueryItem(name: "extras", value: "url_m")
        let queryItem6 = URLQueryItem(name: "format", value: "json")
        let queryItem7 = URLQueryItem(name: "nojsoncallback", value: "1")
        
        components.queryItems!.append(queryItem1)
        components.queryItems!.append(queryItem2)
        components.queryItems!.append(queryItem3)
        components.queryItems!.append(queryItem4)
        components.queryItems!.append(queryItem5)
        components.queryItems!.append(queryItem6)
        components.queryItems!.append(queryItem7)

        print(components.url!)
        
        return components.url!
    }
    
    // Send URL and Parse returned JSON data
    private class func sendReguest(url:URL) -> [PhotoURL]{
        
        var results = [PhotoURL]()
        
        if let data = try? Data(contentsOf: url) {
//            print("##### JSON data is \(data)")
            let json = try? JSON(data:data)
//            let json = parseJSON(data: data)
//            print("##### convered JSON data is \(json)")

//            if json["metadata"]["responseInfo"]["status"].intValue == 200 {
            if json!["stat"].stringValue == "ok" {

//                print("##### JSON data is OK : \(json)")
                results =  parse(json: json!)
            
            }
        }
        
        return results
    }
    
    // Parse JSON
    private class func parse(json:JSON) -> [PhotoURL]{
        
        var results=[PhotoURL]()
        for photo in json["photos"]["photo"].arrayValue {
            
            var obj = PhotoURL()
            obj.id = photo["id"].stringValue
            obj.url_m = photo["url_m"].stringValue

            results.append(obj)
            
        }
        return results
        
    }

    
    private class func parseJSON (data:Data) -> [String:AnyObject] {
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            
//            displayError("$$$  Could not parse the data as JSON: '\(data)'")
            print("$$$  Could not parse the data as JSON: '\(data)'")

            return [:]
        }
        return parsedResult
    }

    static func getDataFromURL(url:URL) -> Data{
        var returnData = Data()
        if let data = try? Data(contentsOf: url) {
            
            returnData = data
            //            print("$$$ loading data from external URL and store it to photoArray and Context")
            
        }
        return returnData
    }
}
