//
//  CameraCollectionViewCell.swift
//  ZoneMinder
//
//  Created by Devsena on 19/12/22.
//

import Foundation
import UIKit

class CameraCollectionViewCell:UICollectionViewCell
{
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var cameraImageView: UIImageView!
    {
        didSet
        {
            cameraImageView.layer.cornerRadius = 30
            cameraImageView.clipsToBounds = true
        }
    }
    
    fileprivate var stream:MJPEGStreamLib!
    fileprivate var spinner:UIActivityIndicatorView!
    
    fileprivate let scaleFactor: CGFloat = 1.4
    
    internal var title: String?
    {
        didSet {
            self.labelTitle.text = title
            // temp
            self.labelStatus.textColor = .cyan
            self.labelStatus.text = "IDLE"
        }
    }
      
    internal var cameraURL: String?
    {
        didSet
        {
            if self.stream == nil || self.stream.status == .stop
            {
                self.stream = MJPEGStreamLib(imageView: cameraImageView)
                DataManager.getInstance.storeStreamReference(stream: self.stream)
            }
            
            stream.didStartLoading = { [unowned self] in
                self.updateSpinnerView(show: true)
            }
            stream.didFinishLoading = { [unowned self] in
                self.updateSpinnerView(show: false)
            }
            
            let url = URL(string:cameraURL!)
            stream.contentURL = url
            stream.play()
        }
    }
    
    fileprivate var titleLabel: UILabel!
    {
        didSet
        {
            titleLabel.textColor = .black
            titleLabel.font = titleLabel.font.withSize(16)
            addSubview(titleLabel)
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if context.nextFocusedView == self
        {
            self.setUnsetBorder(isSet: true)
        }
        else
        {
            self.setUnsetBorder(isSet: false)
        }
    }
    
    fileprivate func setUnsetBorder(isSet:Bool)
    {
        if isSet
        {
            self.cameraImageView.layer.borderColor = UIColor.white.cgColor
            self.cameraImageView.layer.borderWidth = 10
            self.cameraImageView.layer.cornerRadius = 30
        }
        else
        {
            self.cameraImageView.layer.borderWidth = 0
        }
    }
    
    fileprivate func updateSpinnerView(show:Bool)
    {
        if (show)
        {
            spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = UIColor.lightGray
            addSubview(spinner)

            spinner.translatesAutoresizingMaskIntoConstraints = false
            
            spinner.centerXAnchor.constraint(equalTo: (centerXAnchor)).isActive = true
            spinner.centerYAnchor.constraint(equalTo: (centerYAnchor)).isActive = true
            spinner.startAnimating()
        }
        else if (!show)
        {
            DispatchQueue.main.async{
                self.spinner.stopAnimating()
                self.willRemoveSubview(self.spinner)
            }
        }
    }
}
