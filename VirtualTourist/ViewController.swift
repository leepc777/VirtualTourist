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

    var delelat : Double!
    var delelon : Double!

    
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
            
            // add new pin to Context and locationArray
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
    

    func deletePin (lat:Double,lon:Double) {
        
        for pin in pinArray {
            if pin.latitude == lat && pin.longitude == lon {
                context.delete(pin)
                loadPins()
            } else {
                print("$$$ failed to dele Pin in func deletePin")
            }
        }
        
    }
    
}

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

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("&&&   mapView annotationView view got called")
        let annotation = view.annotation
        
        if control == view.rightCalloutAccessoryView {
            print("$$$   control is at right")
            
            
                }
        if control == view.leftCalloutAccessoryView {
            print("$$$   control is at left")
            self.updateAlert(title: "Update", message: "OK to Delete ?")
            delelat = annotation?.coordinate.latitude
            delelon = annotation?.coordinate.longitude

//            deletePin(lat: (view.annotation?.coordinate.latitude)!, lon: (view.annotation?.coordinate.longitude)!)
            
            
        }
        
    }
    
    func updateAlert (title:String,message:String) {
    
        let alert = UIAlertController(title: "Please confirm to delete", message: message, preferredStyle: UIAlertControllerStyle.alert)

        //Cancel Button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (actionHandler) in
            alert.dismiss(animated: true, completion: nil)
        }))

        //Delete Button
        let deleAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.deletePin(lat: self.delelat, lon: self.delelon)
            print("you just delete it !!!!!!!!!!!!!!!")
        }
        alert.addAction(deleAction)
        present(alert, animated: true, completion: nil)

    }
    
}
