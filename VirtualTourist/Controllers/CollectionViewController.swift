//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Patrick on 2/8/18.
//  Copyright © 2018 patrick. All rights reserved.
//
import UIKit
import CoreData


class CollectionViewController: UICollectionViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var photoArray = [Photo]()
    var filteredURLs = [PhotoURL]()
    var urlArray = [PhotoURL]()
    let activityIndicator = UIActivityIndicatorView()

    var selectedPin : Pin! {
        didSet {
//            urlArray = PhotoLib.getPhotoURLs(lat: selectedPin.latitude, lon: selectedPin.longitude)
        }
    }
    
    
    
    //MARK: refresh Collection View
    @objc func didTapSearchButton(sender: AnyObject){

        print("$$$$$$$$$ search button got tapped,view is \(view) and self.view \(self.view)")

        //MARK: - set up indicator
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()

        performUIUpdatesOnMain {
            self.urlArray = PhotoLib.getPhotoURLs(lat: self.selectedPin.latitude, lon: self.selectedPin.longitude)
            self.removePhotos()
            self.getImgsFromURLs()
            
            //stop indicator after view appear
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()

        }
//        urlArray = PhotoLib.getPhotoURLs(lat: selectedPin.latitude, lon: selectedPin.longitude)
//        removePhotos()
//        getImgsFromURLs()
        
//        //stop indicator after view appear
//        activityIndicator.stopAnimating()
//        UIApplication.shared.endIgnoringInteractionEvents()

        collectionView?.reloadData()
        
        print("$$$$$$$$$ search button got completed,view is \(view) and self.view \(self.view)")

    }

    //MARK: - delete/emtpy stored Photos for selectedPin from context and PhotoArray
    func removePhotos() {
        
        for photo in photoArray {
            context.delete(photo)
        }
        photoArray.removeAll()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - set up indicator
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
//        UIApplication.shared.beginIgnoringInteractionEvents()

        print("$$$$$$$$ viewDidLoad got called.    $$$$$$$$$$$")
        
        //setup up search and edit buttons
        //        navigationItem.rightBarButtonItems = [editButtonItem,editButtonItem]
        let searchImage = UIImage(named: "search")!
        let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearchButton))
        navigationItem.rightBarButtonItems = [searchButton, editButtonItem]
        
        
        // change the layout of the colleciton view
        let collectionViewWidth = collectionView?.frame.width
        let itemWidth = (collectionViewWidth! - Storyboard.leftAndRightPadding) / Storyboard.numberOfItemsPerRow
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        
        
        print("!!!!! ViewDidLoad compelted, the coordinate of this Pin is \(selectedPin.latitude) and \(selectedPin.longitude) and the stored photos at this location is \(photoArray.count) and total URLs for this locaiton is \(urlArray.count)" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("$$$$$$$$   viewWillAppear got called  $$$$$$")

    }
    override func viewDidAppear(_ animated: Bool) {
        
        print("$$$$$$$$   viewDidAppear got called  $$$$$$")
        
                //MARK: Prepare data for collection view.
                // 1. fetch photos from context to photoArray to show stored Photos
                fetchPhotos()
        
                // 2. get all URLs for this location(selectedPin)
                urlArray = PhotoLib.getPhotoURLs(lat: selectedPin.latitude, lon: selectedPin.longitude)
        
                // 3. filter & pick 15 random URLs to download images to photoArray which is data souce for collection view.
//                getImgsFromURLs()
        
        
        performUIUpdatesOnMain {
            print("%%%% Call GCD to sumbit getImgsFromURLs()")
            self.getImgsFromURLs()
            self.collectionView?.reloadData()
            //stop indicator after view appear
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()

        }

        
        
        
        print("!!!!! ViewDidAppear compelted, the coordinate of this Pin is \(selectedPin.latitude) and \(selectedPin.longitude) and the stored photos at this location is \(photoArray.count) and total URLs for this locaiton is \(urlArray.count)" )
    }
 

    // MARK: Collection View Data Source , UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("%%%%%%%%%%  numberOfItem got trigger %%%%%%%%%%%%%% ")

        return photoArray.count
//        return filteredURLs.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
//        cell.imageView.image = UIImage(named: "finn") //finn is local image
//        cell.imageView.image = UIImage(data: photoArray[indexPath.row].image!)

        performUIUpdatesOnMain {
            cell.imageView.image = UIImage(data: self.photoArray[indexPath.row].image!)
        }
        
        
        print("%%%%%%%%%%  cellForItemAt got trigger %%%%%%%%%%%%%% ")

        return cell
        
    }

    
    
    //MARK: - Editing Mode setup , disable search button in Editing mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print("#### setEditing was called")

        if editing == true {
            navigationItem.rightBarButtonItem?.isEnabled = false
            print("#### editing is true. setEditing was called")
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
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
    //MARK: Fetch Photos
    func fetchPhotos(with request:NSFetchRequest<Photo> = Photo.fetchRequest(), predicate:NSPredicate?=nil) {
        
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

    

//MARK:  fitler the URLs and call PhotoLib Class to download images.Then store to Context and photoArray
/*
1. if there No photos in Core Data for this pin, download UPTO 15 random photos from Flickr.
2. if there is Zero photo for this Pin from Flickr. Show Aler View to info user no photos are avabile.
3. if there is less than 15 photos avabile from Flickr. Then download all those photos.
*/

    func getImgsFromURLs() {
        print("&&&&&&& getImgsFromURLs got called")
        
        let urlArrayCount = urlArray.count
        
        if photoArray.count == 0 {
            print("!!!!!!no photos in Context for this Pin, so we can get Flickr photos ")
            
            if urlArrayCount == 0 {
                showMessage(title: "Flickr doesn't have photos for this location", message: "Pick another Location")
                print("@@@@@@@@@@  can't find any pictures at this Pin")
            } else {
                
                // set the max number of photos showing in the collecition view as 15
                let numberofShowingPhotos = urlArray.count<15 ? urlArray.count:15
                print ("@@@@@@@@@   Flickr has \(urlArray.count) pictures for this location")
                for index in 0 ..< numberofShowingPhotos {
                    let randomIndex = Int(arc4random()) % urlArrayCount
                    let randomURL = urlArray[randomIndex] // randomURL is PhotoURL type,contains iD/URL
//                    print("@@@@@@   randomURL at index:\(index) is \(randomURL)")
                    
                    // store returned Image data to Photo entity
                    let newPhoto = Photo(context: self.context)
                    newPhoto.image = PhotoLib.getDataFromURL(urlString: randomURL.url_m)
                    newPhoto.id = randomURL.id
                    newPhoto.parentPin = self.selectedPin
                    
                    // Build photoArray for Collection View Data Source
                    self.photoArray.append(newPhoto)
                    self.filteredURLs.append(randomURL)
//                    let insertedIndexPath = IndexPath(item: photoArray.count, section: 0)
//                    collectionView?.deleteItems(at: [insertedIndexPath])
//                    collectionView?.insertItems(at: [insertedIndexPath])

                    //                    collectionView?.reloadData()
                }
            }
            
        } else {print("##### Found stored Photos for this location . NO need to download")}
        
        //stop indicator after view appear
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()

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


