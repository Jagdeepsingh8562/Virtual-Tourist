//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Jagdeep Singh on 02/04/21.
//

import UIKit
import MapKit
import CoreData

class PhotoViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource {
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var dataController: DataController!
    var pin: Pin!
    var selectedAnnotation = MKPointAnnotation()
    var urls = [URL]()
    var imagesData =  [Collection]()
    func isLoading(_ a :Bool) {
        if a {
            activityView.startAnimating()
            newCollectionButton.isEnabled = false
        }
        else {
            activityView.stopAnimating()
            newCollectionButton.isEnabled = true
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        navigationController?.navigationBar.isHidden = false
        isLoading(true)
        FlickerAPI.getPhotosId(lat: selectedAnnotation.coordinate.latitude, long: selectedAnnotation.coordinate.longitude, completion: handleGetPhoto(success:error:))

        setupFlowLayout()
        setupFetchedRequest()
       
    }
    fileprivate func setupFetchedRequest() {
        let fetchRequest:NSFetchRequest<Collection> = Collection.fetchRequest()
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        if let  result = try? dataController.viewContext.fetch(fetchRequest){
            imagesData = result
            ///faltu testing
            if imagesData.count == 0 {
                print("data is not comming") }
            else {
                print("data is \(imagesData.count)")
            }
            //delete krdena
            
            for imageData in imagesData {
                guard let data = imageData.photo else {
                    return
                }
                let image = UIImage(data: data)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: collectionView.indexPath(for: CustomCollectionCell())!) as! CustomCollectionCell
                cell.imageView.image = image
            }
            collectionView.reloadData()
        }
    }
    func setupFlowLayout() {
            let space:CGFloat = 2.0
            let dimension = (view.frame.size.width - (2 * space)) / 3.0
            flowLayout.minimumInteritemSpacing = space
            flowLayout.minimumLineSpacing = space
            flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    
    func handleGetPhoto(success: Bool, error: Error?){
        isLoading(false)
        if success {
            urls = FlickerAPI.getPhotoURL(photoIdArray: FlickerAPI.Auth.photosInfo)
        }
        else {
            print(error!)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
//
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionCell
        cell.imageView.image = nil
        FlickerAPI.getPhotoss(index: indexPath.item) { (imgData) in
            guard let imgData = imgData else {
                return
            }
            let photo = Collection(context: self.dataController.viewContext)
            photo.photo = imgData
            try? self.dataController.viewContext.save()
            self.imagesData.insert(photo, at: 0)
            cell.imageView.image = UIImage(data: imgData)
        }
        
            
        
        
        return cell
    }
    
}

extension PhotoViewController: MKMapViewDelegate {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
//        let selectedAnnotation = MKPointAnnotation()
//        selectedAnnotation.coordinate = coordinate
        mapView.addAnnotation(selectedAnnotation)
        mapView.showAnnotations([selectedAnnotation], animated: true)
        collectionView.reloadData()
    }
}
