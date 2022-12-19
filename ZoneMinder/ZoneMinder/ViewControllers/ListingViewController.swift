//
//  ListingViewController.swift
//  ZoneMinder
//
//  Created by Santanu Karar on 19/12/22.
//

import Foundation
import UIKit

class ListingViewController: UIViewController
{
    @IBOutlet weak var listingCollectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}

extension ListingViewController:UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = self.listingCollectionView.dequeueReusableCell(withReuseIdentifier: "monitorThumbnail", for: indexPath) as! CameraCollectionViewCell
        
        return cell
    }
}
