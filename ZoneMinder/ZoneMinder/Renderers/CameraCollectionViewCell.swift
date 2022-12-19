//
//  CameraCollectionViewCell.swift
//  ZoneMinder
//
//  Created by Santanu Karar on 19/12/22.
//

import Foundation
import UIKit

class CameraCollectionViewCell:UICollectionViewCell
{
    var stream:MJPEGStreamLib!
    
    internal var title: String?
    {
        didSet {
            self.titleLabel.text = title
        }
    }
      
    internal var cameraURL: String?
    {
        didSet {
            let url = URL(string:cameraURL!)
            self.stream.contentURL = url
            self.stream.play()
        }
    }
    
    fileprivate var cameraImageView: UIImageView!
    {
        didSet {
            cameraImageView.adjustsImageWhenAncestorFocused = true
            addSubview(cameraImageView)
        }
    }
    
    fileprivate var titleLabel: UILabel!
    {
        didSet {
            titleLabel.textColor = .white
            titleLabel.font = titleLabel.font.withSize(16)
            addSubview(titleLabel)
      }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setupUI()
    }
      
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    internal func setupUI()
    {
        self.cameraImageView = UIImageView()
        self.titleLabel = UILabel()
        
        stream = MJPEGStreamLib(imageView: self.cameraImageView)
    }
}
