//
//  ListingViewController.swift
//  ZoneMinder
//
//  Created by Devsena on 19/12/22.
//

import Foundation
import UIKit

class ListingViewController: UIViewController
{
    @IBOutlet weak var listingCollectionView: UICollectionView!
    @IBOutlet weak var cameraDetails1: UILabel!
    @IBOutlet weak var cameraDetails2: UILabel!
    
    var testCollection = [CameraItemVO]()
    
    fileprivate let cellOffset: CGFloat = 1.4
    fileprivate var collectionCellIdentifier = "cameraListingCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        listingCollectionView.register(CameraCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        listingCollectionView.delegate = self
        listingCollectionView.dataSource = self
        listingCollectionView.backgroundColor = .clear
        
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera A", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera B", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera C", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera D", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera E", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera F", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera G", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera H", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera I", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera J", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera K", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        testCollection.append(CameraItemVO(dominoUniversalID: "", cameraID: "ABCD", cameraName: "Camera L", url: "", frequency: 30, group: "Group A", subGroup: "SubGroup A"))
        
        
        //let layout = UICollectionViewFlowLayout()
        //layout.scrollDirection = .vertical
        //listingCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    }
    
    /*override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        //listingCollectionView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        let thumbWidth = CGFloat(320)
        let thumbHeight = CGFloat(thumbWidth * 0.8)
        let itemSize = CGSize(width: thumbWidth, height: thumbHeight)
        
        //let itemSize = CGSize(width: self.view.bounds.width * 0.18, height: 160)
        listingCollectionView.contentSize = CGSize(width: self.view.bounds.width - 100, height: self.view.bounds.height)
        (listingCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = itemSize
    }*/
    
    fileprivate func updateCameraDetailsLabels(item:CameraItemVO)
    {
        self.cameraDetails1.text = String.localizedStringWithFormat("%@ (%@)", item.cameraName, item.cameraID)
        self.cameraDetails2.text = String.localizedStringWithFormat("Frequency: %@, DominoUniversalID: (%@)", String(item.frequency), item.dominoUniversalID)
    }
}

extension ListingViewController:UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return testCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = self.listingCollectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! CameraCollectionViewCell
        
        cell.title = testCollection[indexPath.row].cameraName
        cell.cameraURL = String.localizedStringWithFormat("https://zm-node-s2-01.prominic.net/zm/cgi-bin/nph-zms?scale=0&mode=jpeg&maxfps=30&monitor=90&user=Prominic&connkey=6838%@&rand=1666630366", String(indexPath.row))
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cameraFSView = UIStoryboard.cameraFSViewController() as! CameraFullscreenViewController
        cameraFSView.camera = self.testCollection[indexPath.row]
        
        present(cameraFSView, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if collectionView == self.listingCollectionView
        {
            guard (context.nextFocusedIndexPath != nil) else {return}
            self.updateCameraDetailsLabels(item: self.testCollection[context.nextFocusedIndexPath!.row])
        }
    }
}

extension ListingViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: cellOffset / 2, left: cellOffset, bottom: cellOffset / 2, right: cellOffset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellOffset
      }
      
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return cellOffset
      }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let thumbWidth = CGFloat(320)
        let thumbHeight = CGFloat(thumbWidth * 0.7)
        return CGSize(width: thumbWidth, height: thumbHeight)
    }
}
