//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Jagdeep Singh on 02/04/21.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController , MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dataController:DataController!
    var pinArray = [Pin]()
    var selectedpin:Pin!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController = appDelegate.dataController
        setUpMapView()
        setupFetchedRequest()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func setUpMapView() {
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_ :)))
        longTouch.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longTouch)
    }
    
    fileprivate func setupFetchedRequest() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let  result = try? dataController.viewContext.fetch(fetchRequest){
            pinArray = result
            
            for pin in pinArray {
                let cordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = cordinate
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    @objc func addPin(_ gestureReconizer: UILongPressGestureRecognizer) {
           if gestureReconizer.state == .began {
               let location = gestureReconizer.location(in: mapView)
               let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
               let annotation = MKPointAnnotation()
               annotation.coordinate = coordinate
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            try? dataController.viewContext.save()
            
            pinArray.append(pin)
            mapView.addAnnotation(annotation)
           }
       }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let albumVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        albumVC.pin = selectedPin(view: view)
        albumVC.dataController = dataController
        navigationController?.pushViewController(albumVC, animated: true)
        
      
        }

    private func selectedPin(view: MKAnnotationView) -> Pin {
        var selectedPin: Pin!
        for pin in pinArray {
            if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude {
                selectedPin = pin
            }
        }
        return selectedPin
    }
}
   
    



