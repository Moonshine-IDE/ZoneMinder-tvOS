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
    fileprivate var stream:MJPEGStreamLib!
    fileprivate var spinner:UIActivityIndicatorView!
    
    fileprivate let scaleFactor: CGFloat = 1.4
    
    internal var title: String?
    {
        didSet {
            self.titleLabel.text = title
        }
    }
      
    internal var cameraURL: String?
    {
        didSet
        {
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

    fileprivate var cameraImageView: UIImageView!
    {
        didSet
        {
            cameraImageView.adjustsImageWhenAncestorFocused = true
            addSubview(cameraImageView)
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
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let titleImageViewHeight = bounds.height - bounds.height / 8
            let labelHeight = bounds.height - titleImageViewHeight
            
        cameraImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: titleImageViewHeight - 20)
        titleLabel.frame = CGRect(x: 0, y: cameraImageView.frame.maxY + 10, width: bounds.width, height: labelHeight).integral
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if context.nextFocusedView == self
        {
            UIView.animate(withDuration: 0.2, animations: {
                self.titleLabel.isHidden = true
            })
        }
        else
        {
            UIView.animate(withDuration: 0.2) {
                self.titleLabel.isHidden = false
            }
        }
    }

    internal func setupUI()
    {
        cameraImageView = UIImageView()
        titleLabel = UILabel()
        
        stream = MJPEGStreamLib(imageView: cameraImageView)
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
