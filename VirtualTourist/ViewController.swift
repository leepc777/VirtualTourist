//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Patrick on 2/7/18.
//  Copyright © 2018 patrick. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    }


    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
//        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        
//        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.760122, -122.468158)
        
        //        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        //        map.setRegion(region, animated: true)

        
        let locationCGP = sender.location(in: self.map)
        let location = self.map.convert(locationCGP, toCoordinateFrom: self.map)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = " \(location)"
        annotation.subtitle = " come visit me here !"
        
        map.removeAnnotations(map.annotations)
        map.addAnnotation(annotation)
        
        let lat = location.latitude
        let lon = location.longitude as Double
        
        print("$$$ current location: \(location) and \(locationCGP)")
        
        
        
    }
    
}

