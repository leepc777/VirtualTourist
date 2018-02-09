//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Patrick on 2/7/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var pinArray = [Pin]()

    var selectedlat : Double!
    var selectedlon : Double!
    var selectedPin = Pin()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPins()
        
        
//        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
//        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.760122, -122.468158)
//        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//        map.setRegion(region, animated: true)
//
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location
//        annotation.title = " my shop"
//        annotation.subtitle = " come visit me here !"
//        map.addAnnotation(annotation)
        
        
        print("&&& where is our data",FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        savePins() // this will store context back to store
    }

    //MARK: - Add new Pin by long Press Gesture
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
        //        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        
        //        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.760122, -122.468158)
        
        //        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        //        map.setRegion(region, animated: true)
        
        
        
        if sender.state == .began {
            
            let locationCGP = sender.location(in: self.map)
            let location = self.map.convert(locationCGP, toCoordinateFrom: self.map)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "tap right to add photos"
            annotation.subtitle = " tap left to delete"
            map.addAnnotation(annotation)
            
            print("long press began")
            
            // add new Pin to Context and locationArray
            let newPin = Pin(context: self.context)
            newPin.latitude = location.latitude
            newPin.longitude = location.longitude
            pinArray.append(newPin)
            savePins()
            
            print("$$$ pinArray : \(pinArray)")
            
        }
        else if sender.state == .ended {
//            map.removeAnnotations(map.annotations)
            loadPins()
            print("^^^ Long Press ended")
        }
    }
    
    
    //MARK: - Model Manupulation Methods
    
    //write unsaved changes from context to store
    
    func savePins() {
        do {
            try context.save()
        } catch {
            print("$$$ Error saving context,\(error)")
        }
        
    }
    
    // fetch all Pins from store to pinArray and showing in Map
    func loadPins() {
        
        map.removeAnnotations(map.annotations)
        let request : NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            pinArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context :\(error)")
        }
        
        for pin in pinArray {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
//            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotation.title = "tap right to add photos"
            annotation.subtitle = " tap left to delete"
            map.addAnnotation(annotation)

        }
        

    }
    

    //MARK: -- Deleate Pins from context and pinArray
    func deletePin (lat:Double,lon:Double) {
        
        for pin in pinArray {
            if pin.latitude == lat && pin.longitude == lon {
                
                print("####  find the mached Pin in pinArray")
                context.delete(pin)
                loadPins()
                break
            } else {
                print("$$$ failed to dele Pin in func deletePin")
            }
        }
        
    }
    
    //MARK: - find Pin. find and read out the Pin object from pinArray based on Lat&Lon
    func findPin (lat:Double,lon:Double) -> Pin {
        
        var matchedPin = Pin()
        for pin in pinArray {
            if pin.latitude == lat && pin.longitude == lon {
                matchedPin = pin
                print("####  find the mached Pin in pinArray")
                break
            } else {
                print("$$$ No match Pin in the current pinArray")
            }
        }
        
        return matchedPin

    }
    
}

//MARK: - Map delegation. Optional delegate methods
extension ViewController : MKMapViewDelegate {
    
    // MARK: Wire a button to the pin to bring up confirmation window
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        print("&&&   mapView viewFor annotation got called")
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.orange
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            pinView!.leftCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        }
            
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    // Right and Left actions after tapping the Pin
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("&&&   mapView annotationView view got called")
        let annotation = view.annotation
        
        if control == view.rightCalloutAccessoryView {
            print("$$$   control is at right")
            self.selectedPin = findPin(lat: (annotation?.coordinate.latitude)!, lon: (annotation?.coordinate.longitude)!)
            performSegue(withIdentifier: "goToPhotos", sender: self)

            
                }
        if control == view.leftCalloutAccessoryView {
            print("$$$   control is at left")
            self.updateAlert(title: "Update", message: "OK to Delete ?")
            selectedlat = annotation?.coordinate.latitude
            selectedlon = annotation?.coordinate.longitude

//            deletePin(lat: (view.annotation?.coordinate.latitude)!, lon: (view.annotation?.coordinate.longitude)!)
            
            
        }
        
    }
    
    //MARK: - Prepare Data for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! CollectionViewController
        nextVC.selectedPin = self.selectedPin
    }

    
    
    func updateAlert (title:String,message:String) {
    
        let alert = UIAlertController(title: "Please confirm to delete", message: message, preferredStyle: UIAlertControllerStyle.alert)

        //Cancel Button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (actionHandler) in
            alert.dismiss(animated: true, completion: nil)
        }))

        //Delete Button
        let deleAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.deletePin(lat: self.selectedlat, lon: self.selectedlon)
            print("you just delete it !!!!!!!!!!!!!!!")
        }
        alert.addAction(deleAction)
        present(alert, animated: true, completion: nil)

    }
    
}


