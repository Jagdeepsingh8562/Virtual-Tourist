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
    var annotationArray = [CLLocationCoordinate2D]()
    var selectedAnnotation = MKPointAnnotation()
    var urls = [URL]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_ :)))
        longTouch.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longTouch)
    }
    @objc func addPin(_ gestureReconizer: UILongPressGestureRecognizer) {
           if gestureReconizer.state == .began {
               let location = gestureReconizer.location(in: mapView)
               let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
               let annotation = MKPointAnnotation()
               annotation.coordinate = coordinate
            annotationArray.append(annotation.coordinate)
               mapView.addAnnotation(annotation)
           }
       }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as! MKPointAnnotation
        FlickerAPI.getPhotosId(lat: selectedAnnotation.coordinate.latitude, long: selectedAnnotation.coordinate.longitude, completion: handleGetPhotoId(success:error:))
        

        }
    func handleGetPhotoId(success: Bool, error: Error?){
        if success {
            urls = FlickerAPI.getPhotoURL(photoIdArray: FlickerAPI.Auth.photosInfo)
            performSegue(withIdentifier: "photoSegue", sender: nil)        }
        else {
            print(error!)
        }
    }
 
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? PhotoViewController {
            target.selectedAnnotation = selectedAnnotation
            target.urls = urls
        }
    }
    
   
    

}

