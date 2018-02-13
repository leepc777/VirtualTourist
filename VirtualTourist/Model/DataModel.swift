//
//  DataModel.swift
//  VirtualTourist
//
//  Created by sam on 2/10/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit

struct Storyboard {
    static let leftAndRightPadding: CGFloat = 2.0
    static let numberOfItemsPerRow: CGFloat = 3.0
}

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
        let request = buildRequestURL(lat:lat, lon:lon)
        
//        performUIUpdatesOnMain {
//            results = sendReguest(url: request)
//
//        }
        
        results = sendReguest(request: request,lat: lat,lon: lon)
        
        //check page number and get 2nd result back.
        
//        print("####### PhotoLib.getPhotoURLs : 1st Requested HTTP url to Flickr is \(request)")
        return results
    }
    
//    //check pages and randomly pick one page and get another 2nd JSON result back.
//    class func requestWithRandomPage(results:[PhotoURL]) -> [PhotoURL] {
//        var newResult = [PhotoURL]()
//        let result = results[0]
//        
//        return newResult
//    }
    
    //build URL
    class func buildRequestURL(lat:Double=0,lon:Double=0,numberOfPage:String = "1") -> URL {
        
//        let numberOfPage : Int
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
        let queryItem8 = URLQueryItem(name: "page", value: numberOfPage)
        
        components.queryItems!.append(queryItem1)
        components.queryItems!.append(queryItem2)
        components.queryItems!.append(queryItem3)
        components.queryItems!.append(queryItem4)
        components.queryItems!.append(queryItem5)
        components.queryItems!.append(queryItem6)
        components.queryItems!.append(queryItem7)
        components.queryItems!.append(queryItem8)


//        print("####### PhotoLib.buildURL: URLComponents URL \(components.url!)")
        
        return components.url!
    }
    
    // Send URL and Parse returned JSON data
    private class func sendReguest(request:URL,lat:Double=0,lon:Double=0) -> [PhotoURL]{
        
        var results = [PhotoURL]()
        
        if let data = try? Data(contentsOf: request) {
            let json = try? JSON(data:data)
            if json!["stat"].stringValue == "ok" {
                if json!["photos"]["pages"] > 1 {
                    print("$$$$$$$$$$   there are more than one pages !")
                    let maxPage = json!["photos"]["pages"].intValue
                    let randomPage = Int(arc4random()) % maxPage
                    let newRequest = buildRequestURL(lat: lat, lon: lon, numberOfPage:String(randomPage))
                    
                    if let data = try? Data(contentsOf: newRequest) {
                        let json = try? JSON(data:data)
                        results =  parse(json: json!)
                        print("2st Requested HTTP url to Flickr is \(newRequest)")
                    }
                    else {print("failt to get Data for the 2nd request (with random page number)")}
                
                } else {
                    print("$$$$$$ only one page !!!!  ")
                    results =  parse(json: json!)
                }
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

    
//    private class func parseJSON (data:Data) -> [String:AnyObject] {
//        let parsedResult: [String:AnyObject]!
//        do {
//            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//        } catch {
//
////            displayError("$$$  Could not parse the data as JSON: '\(data)'")
//            print("$$$  Could not parse the data as JSON: '\(data)'")
//
//            return [:]
//        }
//        return parsedResult
//    }

    
    // Load Image from URL
    static func getDataFromURL(urlString:String) -> Data{
        let url = URL(string:urlString)!
        var returnData = Data()
        if let data = try? Data(contentsOf: url) {
            
            returnData = data
            //            print("$$$ loading data from external URL and store it to photoArray and Context")
            
        }
        return returnData
    }
}
