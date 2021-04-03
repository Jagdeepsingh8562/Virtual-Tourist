//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Jagdeep Singh on 02/04/21.
//

import UIKit
import MapKit

class PhotoViewController: UIViewController, UICollectionViewDelegate ,MKMapViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
    }
}
