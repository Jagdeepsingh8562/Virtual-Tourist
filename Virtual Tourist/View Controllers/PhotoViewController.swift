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
    var imagesDataArray =  [Collection]()
    var imagesArrayHasData:Bool = false
    
    
    func isLoading(_ a :Bool) {
        if a {
            activityView.startAnimating()
            newCollectionButton.isEnabled = false
            collectionView.isUserInteractionEnabled = false
        }
        else {
            activityView.stopAnimating()
            newCollectionButton.isEnabled = true
            collectionView.isUserInteractionEnabled = true
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
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            try? dataController.viewContext.save()
        }
    
    fileprivate func setupFetchedRequest() {
        let fetchRequest:NSFetchRequest<Collection> = Collection.fetchRequest()
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        if let  result = try? dataController.viewContext.fetch(fetchRequest){
            imagesDataArray = result
            if !result.isEmpty {
                print("result is not empty")
                imagesArrayHasData = true
            }
            ///faltu testing
            if imagesDataArray.count == 0 {
                print("data empty")
            }
            else {
                print("data is \(imagesDataArray.count)")
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
        cell.imageView.image = UIImage(named: "imagePlaceholder")
        if imagesArrayHasData == false {
        FlickerAPI.getPhoto(index: indexPath.item) { (image, urlString) in
            guard let image = image else {
                return
            }
            
            let photo = Collection(context: self.dataController.viewContext)
            photo.photo = image.pngData()
            photo.pin = self.pin
            self.imagesDataArray.append(photo)
            
            try? self.dataController.viewContext.save()
          
            if indexPath.row == self.imagesDataArray.count - 1 {
                self.imagesArrayHasData = true
                collectionView.isUserInteractionEnabled = true
            }
            cell.imageView.image = image
            
            }
            
           
        }
        else {
            let imageData = imagesDataArray[indexPath.item].photo
            cell.imageView.image = UIImage(data: imageData!)
            collectionView.isUserInteractionEnabled = true
            print("core data loading")
        }
            
        
        
        return cell
    }
    
}
let imageCache = NSCache<AnyObject, AnyObject>()

extension PhotoViewController: MKMapViewDelegate {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupFetchedRequest()
        mapView.addAnnotation(selectedAnnotation)
        mapView.showAnnotations([selectedAnnotation], animated: true)
        mapView.isUserInteractionEnabled = false
        collectionView.reloadData()
    }
}
