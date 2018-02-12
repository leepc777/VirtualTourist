//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Patrick on 2/8/18.
//  Copyright © 2018 patrick. All rights reserved.
//
import Foundation
import UIKit
import CoreData

private let reuseIdentifier = "collectionCell"

class CollectionViewController: UICollectionViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var photoArray = [Photo]()
    var testArray = [Data]()
    var urlArray : [PhotoURL]! // store the iD/URL of photos retured by Flickr.

    var selectedPin : Pin! {
        didSet {
            
//            //set up indicator
//                        let activityIndicator = UIActivityIndicatorView()
//                        activityIndicator.center = self.view.center
////                        activityIndicator.center = mapView.center
//
//                        activityIndicator.hidesWhenStopped = true
//                        activityIndicator.activityIndicatorViewStyle = .gray
//                        view.addSubview(activityIndicator)
//                        activityIndicator.startAnimating()

            
            urlArray = PhotoLib.getPhotoURLs(lat: selectedPin.latitude, lon: selectedPin.longitude)
            loadPhotos()
            print("$$$$$$$$$$   Collection get the selectedPin as \(self.selectedPin)")
            print("$$$$ the array storing all ID and URLs for every photos from Flickr \(urlArray) ")
//            getImage()
            
            if photoArray.count == 0 {
                print("!!!!!!no photos in Context for this Pin, getting some PHOTOS !!!!!!!!! ")
            getImgsFromURLs()
            } else {
                
                print("!!!!!!there are some photos at this Pin already!!!!!! !!!!! no need to download more unless you delete some")
                
            }

            
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
//        getImgsFromURLs()
        
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        
        /*
        let imageURL = URL(string: "https://scontent.fsnc1-1.fna.fbcdn.net/v/t31.0-8/27368245_10156168543027002_2810235546452527170_o.jpg?oh=9be751f2dfb484e7cc89af4edfc15bed&oe=5B1C61A0")
        // create network request
        
        if let data = try? Data(contentsOf: imageURL!) {

            // store returned Image data to Photo entity
            let newPhoto = Photo(context: self.context)
            newPhoto.image = data
            newPhoto.id = "test"
            newPhoto.parentPin = self.selectedPin
            self.photoArray.append(newPhoto)
            print("$$$ loading data from external URL in viewDidLoad")

        }
        
        */
        
        /*
                let task = URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
        
                    if error == nil {
                        
                        //store to test Array
                        self.testArray.append(data!)
                        self.testArray.append(data!)
                        self.testArray.append(data!)
                        self.testArray.append(data!)
                        
                        // store returned data to Photo entity
                        let newPhoto = Photo(context: self.context)
                        newPhoto.image = data!
                        newPhoto.title = "test"
                        newPhoto.parentPin = self.selectedPin
                        self.photoArray.append(newPhoto)
                        
                        print("^^^^^^  successfully dataTask to download image in ViewDidLoad")
                        
                        // update UI on a main thread
                        
                    } else {
                        print(error!)
                    }
                }
        
                task.resume()
    */
        
//        let newImageData = UIImageJPEGRepresentation(UIImage(named:"finn")!, 1)
//
//        testArray.append(newImageData!)
//        testArray.append(newImageData!)
//        testArray.append(newImageData!)
//        testArray.append(newImageData!)
        
//        var newPhoto = Photo()
//        newPhoto.image = newImageData
//        newPhoto.title = "test"
//        newPhoto.parentPin = selectedPin

//        photoArray.append(newPhoto)
//        photoArray.append(newPhoto)
//        photoArray.append(newPhoto)
//        photoArray.append(newPhoto)


 
 
print("!!!!! ViewDidLoad compelted, the coordinate of this Pin is \(selectedPin.latitude) and \(selectedPin.longitude)")
    }


 

    // MARK: Collection View Data Source , UICollectionViewDataSource



    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("%%%% testArray count is : \(testArray.count)")
//        return testArray.count
        return photoArray.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
//        cell.imageView.image = UIImage(named: "finn") //finn is local image
//        cell.imageView.image = UIImage(data: testArray[indexPath.row]) //read from testArray
        cell.imageView.image = UIImage(data: photoArray[indexPath.row].image!)

        
//        cell.imageView.image = UIImage(data: testArray[indexPath.row])
//        let photo = photoArray[indexPath.row]
//        cell.imageView.image = UIImage(data: photo.image!)
        
        return cell
    }

    
    
    //MARK: - delete collection cell
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print("#### setEditing was called")

        if editing == true {
            print("#### editing is true. setEditing was called")
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
        context.delete(photoArray[indexPath.row])
        photoArray.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        }
    }

    
    //MARK: - Model Manupulation Methods

    // Read data from store to itemArray,default inputs is reading out All Items belonging to same Category selectedCategory
    
    func loadPhotos(with request:NSFetchRequest<Photo> = Photo.fetchRequest(), predicate:NSPredicate?=nil) {
        
        let pinPredicate = NSPredicate(format: "parentPin == %@", selectedPin!)
        
        
        //optional binding to handle nil at predicate
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pinPredicate,predicate])
        }
        else {
            request.predicate = pinPredicate
        }
        
        do {
            photoArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context :\(error)")
        }
        
        collectionView?.reloadData()
    }

    
}

//MARK:  Flickr -- flickr.photos.search
extension CollectionViewController {
    
    
//    func buildURL(lat:Double=0,lon:Double=0) -> URL {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "api.flickr.com"
//        components.path = "/services/rest"
//        components.queryItems = [URLQueryItem]()
//
//        let queryItem1 = URLQueryItem(name: "method", value: "flickr.photos.search")
//        let queryItem2 = URLQueryItem(name: "api_key", value: "11ebab0e0173a322ca87cee9c81a349a")
//        let queryItem3 = URLQueryItem(name: "lat", value: String(lat))
//        let queryItem4 = URLQueryItem(name: "lon", value: String(lon))
//        let queryItem5 = URLQueryItem(name: "extras", value: "url_m")
//        let queryItem6 = URLQueryItem(name: "format", value: "json")
//
//        components.queryItems!.append(queryItem1)
//        components.queryItems!.append(queryItem2)
//        components.queryItems!.append(queryItem3)
//        components.queryItems!.append(queryItem4)
//        components.queryItems!.append(queryItem5)
//        components.queryItems!.append(queryItem6)
//
//        print(components.url!)
//
//        return components.url!
//    }
    
    //MARK: get images and store them to photoArray and Context
    func getImgsFromURLs() {
        //        print("#### urlArray is \(urlArray)")
        let count = urlArray.count
        
        if count == 0 {
            print("@@@@@@@@@@  can't find any pictures at this Pin")
        } else {
            
//            if photoArray.count < urlArray.count
            
            // set the max number of photos showing in the collecition view as 15
            let numberofShowingPhotos = urlArray.count<15 ? urlArray.count:15
            print ("@@@@@@@@@  remaind is \(remainder) , photoArray.count is \(photoArray.count)")
            for index in 0 ..< numberofShowingPhotos {
                let randomIndex = Int(arc4random()) % count
                let idURL = urlArray[randomIndex] // idURL is PhotoURL type
                print("@@@@@@   idURL at index:\(index) is \(idURL)")
                let urlString = idURL.url_m
                let url = URL(string:urlString)
                let id = urlArray[randomIndex].id
                
                if let data = try? Data(contentsOf: url!) {
                    
                    // store returned Image data to Photo entity
                    let newPhoto = Photo(context: self.context)
                    newPhoto.image = data
                    newPhoto.id = id
                    newPhoto.parentPin = self.selectedPin
                    self.photoArray.append(newPhoto)
                    print("$$$ loading data from external URL and store it to photoArray and Context")
                    
                }
            }
        }
    }
    
    
//    func getImage()  {
//
//        let imageURL = URL(string: "https://farm5.staticflickr.com//4567//38084351084_c82a317880.jpg")!
//
//        //        let imageURL = URL(string: "https://scontent.fsnc1-1.fna.fbcdn.net/v/t31.0-8/27368245_10156168543027002_2810235546452527170_o.jpg?oh=9be751f2dfb484e7cc89af4edfc15bed&oe=5B1C61A0")!
//
//        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
//            if error == nil {
//                //                performUIUpdatesOnMain {
//                //                    self.imageView.image = UIImage(data: datax)
//                //                }
//
////                    let tempPhoto = Photo()
////                    tempPhoto.parentPin = self.selectedPin
////                    tempPhoto.image = data
////                    tempPhoto.title = "test"
////                    print("$$$  here is the tempPhoto : \(tempPhoto)")
////                    self.photoArray.append(tempPhoto)
//
//
//                // create image
//                let downloadedImage = UIImage(data: data!)
//
//
//            } else {
//                print("$$$ fail to access URL : \(error)")
//            }
//        }
//        task.resume()
//
//        print("!!!!   getImage got called")
//
////        if let imageData = try? Data(contentsOf: imageURL){
////
////
////
////            print("$$$$ inside for loop")
////            for i in 0...1 {
////                let tempPhoto = Photo()
////                tempPhoto.parentPin = selectedPin
////                tempPhoto.image = imageData
////                tempPhoto.title = "test"
////                print("$$$  here is the tempPhoto : \(tempPhoto)")
////                photoArray.append(tempPhoto)
////            }
////
////        }
////        else {
////            print("failed to load image to photArray")
////        }
//
//
//    }
}


