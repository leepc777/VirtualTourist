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


class CollectionViewController: UICollectionViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var photoArray = [Photo]()
    var urlArray : [PhotoURL]!
    let activityIndicator = UIActivityIndicatorView()

    var selectedPin : Pin! {
        didSet {
//            urlArray = PhotoLib.getPhotoURLs(lat: selectedPin.latitude, lon: selectedPin.longitude)
        }
    }
    
    struct Storyboard {
        static let leftAndRightPadding: CGFloat = 2.0
        static let numberOfItemsPerRow: CGFloat = 3.0
    }

    
    @objc func didTapSearchButton(sender: AnyObject){

        collectionView?.reloadData()
        print("$$$$$$$$$ search button got tapped")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        navigationItem.rightBarButtonItems = [editButtonItem,editButtonItem]
        
        let searchImage = UIImage(named: "search")!
        
        let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearchButton))
        
        navigationItem.rightBarButtonItems = [searchButton, editButtonItem]
        
        
        // change the layout of the colleciton view
        let collectionViewWidth = collectionView?.frame.width
        let itemWidth = (collectionViewWidth! - Storyboard.leftAndRightPadding) / Storyboard.numberOfItemsPerRow
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        
        urlArray = PhotoLib.getPhotoURLs(lat: selectedPin.latitude, lon: selectedPin.longitude)
        
        //MARK: - set up indicator
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        
        
        print("!!!!! ViewDidLoad compelted, the coordinate of this Pin is \(selectedPin.latitude) and \(selectedPin.longitude)")
    }

    override func viewDidAppear(_ animated: Bool) {
        
        
        // Fetching Photos from Store to context and PhotoArray.
        loadPhotos()
//        print("$$$$$$$$$$   Collection get the selectedPin as \(self.selectedPin)")
//        print("$$$$ the array storing all ID and URLs for every photos from Flickr \(urlArray) ")
        
        
        // Only download photos from Flikr when NO photos in local Core Data
        if photoArray.count == 0 {
            print("!!!!!!no photos in Context for this Pin, getting some PHOTOS !!!!!!!!! ")
            getImgsFromURLs()
        } else {
            print("!!!!!!there are some photos at this Pin already!!!!!! !!!!! no need to download more unless you delete some")
        }
        print("!!!!! ViewDidAppear compelted, the coordinate of this Pin is \(selectedPin.latitude) and \(selectedPin.longitude)")
//        collectionView?.reloadData()
        
        //stop indicator after view appear
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
 

    // MARK: Collection View Data Source , UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoArray.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
//        cell.imageView.image = UIImage(named: "finn") //finn is local image

        cell.imageView.image = UIImage(data: photoArray[indexPath.row].image!)
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
    
    //MARK: - Collection delegate method, delete photo in Editing mode. open photo in Not-Editing mode
    var selectedImage: UIImage!
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
        context.delete(photoArray[indexPath.row])
        photoArray.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        } else {
//            cell.imageView.image = UIImage(data: photoArray[indexPath.row].image!)

            selectedImage = UIImage(data: photoArray[indexPath.row].image!)
            performSegue(withIdentifier: "goToPhoto", sender: nil)
        }
    }
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhoto" {
            
            let detailVC = segue.destination as! DetailViewController
            detailVC.image = selectedImage
        }
    }

    
    
    //MARK: - Model Manupulation Methods

    // Read data from store to itemArray,default is reading out All Items belonging to same Category selectedPin
    
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

//MARK:  fitler the URLs and call PhotoLib Class to download images.Then store to Context and photoArray
/*
1. if there No photos in Core Data for this pin, download 15 random photos from Flickr.
2. if there is Zero photo for this Pin from Flickr. Show Aler View to info user no photos are avabile.
3. if there is less than 15 photos avabile from Flickr. Then download all those photos.
*/
 extension CollectionViewController {
    
    func getImgsFromURLs() {
        //        print("#### urlArray is \(urlArray)")
        let count = urlArray.count
        
        if count == 0 {
            showMessage(title: "Flickr doesn't have photos for this location", message: "Pick another Location")
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
                
                // store returned Image data to Photo entity
                let newPhoto = Photo(context: self.context)
                newPhoto.image = PhotoLib.getDataFromURL(url: url!)
                newPhoto.id = id
                newPhoto.parentPin = self.selectedPin
                self.photoArray.append(newPhoto)
                
            }
        }
    }
    
    //Mark: - SHow message through Alert
    func showMessage(title:String,message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        //Cancel Button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (actionHandler) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}


