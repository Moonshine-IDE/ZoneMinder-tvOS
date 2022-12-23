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
    
    fileprivate let cellOffset: CGFloat = 0
    fileprivate var collectionCellIdentifier = "cameraListingCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        DataManager.getInstance.camerasDelegate = self
        
        listingCollectionView.register(CameraCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        listingCollectionView.delegate = self
        listingCollectionView.dataSource = self
        listingCollectionView.backgroundColor = .clear
    }
    
    fileprivate func updateCameraDetailsLabels(item:CameraItemVO)
    {
        self.cameraDetails1.text = String.localizedStringWithFormat("%@ (%@)", item.cameraName, item.cameraID)
        self.cameraDetails2.text = String.localizedStringWithFormat("Frequency: %@", String(item.frequency))
    }
}

extension ListingViewController:UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return DataManager.getInstance.numberOfCamerasInList()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = self.listingCollectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! CameraCollectionViewCell
        
        cell.title = DataManager.getInstance.cameraItemAtIndex(itemAtIndex: indexPath.row).cameraName
        cell.cameraURL = String.localizedStringWithFormat("https://zm-node-s2-01.prominic.net/zm/cgi-bin/nph-zms?scale=0&mode=jpeg&maxfps=30&monitor=90&user=Prominic&connkey=6838%@&rand=1666630366", String(indexPath.row))
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cameraFSView = UIStoryboard.cameraFSViewController() as! CameraFullscreenViewController
        cameraFSView.camera = DataManager.getInstance.cameraItemAtIndex(itemAtIndex: indexPath.row)
        
        present(cameraFSView, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if collectionView == self.listingCollectionView
        {
            guard (context.nextFocusedIndexPath != nil) else {return}
            self.updateCameraDetailsLabels(item: DataManager.getInstance.cameraItemAtIndex(itemAtIndex: context.nextFocusedIndexPath!.row))
        }
    }
}

extension ListingViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        // main frame margin
        return UIEdgeInsets(top: 0, left: cellOffset, bottom: 10, right: cellOffset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        // column gaps
        return 0
    }
      
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        // row gaps
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let collectionViewWidth = self.listingCollectionView.bounds.width
        let thumbWidth = (collectionViewWidth / 3) - 30
        let thumbHeight = CGFloat(thumbWidth * 0.7)
        return CGSize(width: thumbWidth, height: thumbHeight)
    }
}

extension ListingViewController: CamerasDataManagerDelegates
{
    func dataUpdated()
    {
        self.listingCollectionView.reloadData()
    }
}
