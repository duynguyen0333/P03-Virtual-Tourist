//
//  PhotoViewController.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var warningLabel: UILabel!
    
    var photos: [Photo]!
    var pin: Pin!
    var dataController: DataController!
    var page: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()    // removed self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.isHidden = true
        setStaticMapView()
        TouristService.getPhotos(lat: pin.latitude, lon: pin.longitude, page: page, completionHandler: photoSearchResponse(response:error:))
    }
    
    @IBAction func reloadData() {
        page += 1
        pageLoading(loading: true)

        TouristService.getPhotos(lat: pin.latitude, lon: pin.longitude, page: page, completionHandler: photoSearchResponse(response:error:))
    }
    
    func reloadPhotos() {
//        collectionView!.reloadData()
    }
    
    func photoSearchResponse(response: TouristPhotos?, error: Error?) -> Void {
        if let response = response {
            
            for photo in response.photos.photo {
                TouristService.getSizes(photoId: photo.id ?? "") {(response, error) in
                    if let response = response {
                        self.warningLabel.isHidden = true
                        
                        if let newPhoto = response.sizes.size.first  {
                            print("GetSize Photo \(newPhoto.source)")
                            let imageURL = URL(string: newPhoto.url)
                            let currentPhoto = Photo(context: self.dataController.viewContext)
                            
                            currentPhoto.id = photo.id
                            currentPhoto.rawImage = try? Data(contentsOf: imageURL!)
                            currentPhoto.source = URL(string: newPhoto.source)!
                            try? self.dataController.viewContext.save()
                            self.photos.append(currentPhoto)
                        }
                    } else {
                        self.warningLabel.isHidden = false
                    }
                }
            }
        } else {
            self.warningLabel.isHidden = false
            pageLoading(loading: false)
        }
        
    }

    func setupLayout() {
        // Setup collection view background
        collectionView.backgroundColor = .white

        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

    func setStaticMapView() {
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        let cordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.coordinate = cordinate
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        
        let rectangleSide = 5000
        let region = MKCoordinateRegion( center: cordinate, latitudinalMeters: CLLocationDistance(exactly: rectangleSide)!, longitudinalMeters: CLLocationDistance(exactly: rectangleSide)!)
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .systemTeal
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // MARK: Delega function
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }

    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let photo = photos[(indexPath).row]
    
        if let source = photo.source {
            TouristService.downloadImage(url: source) {(url, error) in
                if let url = url {
                    let downloadedImage = UIImage(data: url)
                    if let downloadedImage = downloadedImage {
                        cell.imageView.image = downloadedImage
                        DispatchQueue.main.sync {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }

    
    
    func pageLoading(loading: Bool) {
        warningLabel.isEnabled = !loading
    }
    
}
