//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Jagdeep Singh on 02/04/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController , MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_ :)))
        mapView.addGestureRecognizer(longTouch)
    }
    @objc func addPin(_ gestureReconizer: UILongPressGestureRecognizer) {
           if gestureReconizer.state == .began {
               let location = gestureReconizer.location(in: mapView)
               let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
               let annotation = MKPointAnnotation()
               annotation.coordinate = coordinate
               mapView.addAnnotation(annotation)
           }
       }
        
    
    
   
    

}

