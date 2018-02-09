//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Patrick on 2/8/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "collectionCell"

class CollectionViewController: UICollectionViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var photoArray = [Photo]()
    var selectedPin : Pin? {
        didSet {
            loadPhotos()
            print("$$$ Coollection get the selectedPin as \(self.selectedPin)")
            getImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }


 

    // MARK: UICollectionViewDataSource



    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoArray.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionCell
        let photo = photoArray[indexPath.row]
        cell.imageView.image = UIImage(data: photo.image!)
        
        return cell
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
    
    
    func buildURL(lat:Double=0,lon:Double=0) -> URL {
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
        
        components.queryItems!.append(queryItem1)
        components.queryItems!.append(queryItem2)
        components.queryItems!.append(queryItem3)
        components.queryItems!.append(queryItem4)
        components.queryItems!.append(queryItem5)
        components.queryItems!.append(queryItem6)
        
        print(components.url!)
        
        return components.url!
    }
    
    func getImage() {
        
        //        let imageURL = URL(string: "https://farm5.staticflickr.com//4567//38084351084_c82a317880.jpg")!
        
        let imageURL = URL(string: "https://scontent.fsnc1-1.fna.fbcdn.net/v/t31.0-8/27368245_10156168543027002_2810235546452527170_o.jpg?oh=9be751f2dfb484e7cc89af4edfc15bed&oe=5B1C61A0")!
        
        if let imageData = try? Data(contentsOf: imageURL){
            
            for index in 1...3 {
                photoArray[index].image = imageData
            }
            
            //            self.tempImageView.image = UIImage(data: imageData)
            
        }
    }
}

