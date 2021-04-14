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
    var selectedAnnotation = MKPointAnnotation()
    var selectedpin:Pin!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        dataController = appDelegate.dataController
        setUpMapView()
        setupFetchedRequest()
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
            pin.latitude = selectedAnnotation.coordinate.latitude
            pin.longitude = selectedAnnotation.coordinate.longitude
            try? dataController.viewContext.save()
            
            pinArray.insert(pin, at: 0)
            mapView.addAnnotation(annotation)
           }
       }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as! MKPointAnnotation
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = selectedAnnotation.coordinate.latitude
        pin.longitude = selectedAnnotation.coordinate.longitude
        selectedpin =  pin
        try? dataController.viewContext.save()
        
        performSegue(withIdentifier: "photoSegue", sender: nil)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? PhotoViewController {
            target.selectedAnnotation = selectedAnnotation
            target.dataController = appDelegate.dataController
            target.pin = selectedpin
        }
    }
}
   
    



