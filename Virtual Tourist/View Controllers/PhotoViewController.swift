//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Jagdeep Singh on 02/04/21.
//

import UIKit
import MapKit

class PhotoViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var selectedAnnotation = MKPointAnnotation()
    var urls = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        navigationController?.navigationBar.isHidden = false
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionCell
        FlickerAPI.getPhoto(index: indexPath) { (image) in
            cell.imageView.image = image
            
        }
        
        return cell
    }
    
}

extension PhotoViewController: MKMapViewDelegate {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.addAnnotation(selectedAnnotation)
        mapView.showAnnotations([selectedAnnotation], animated: true)
        collectionView.reloadData()
    }
}
