//
//  CameraCollectionViewCell.swift
//  ZoneMinder
//
//  Created by Devsena on 19/12/22.
//

import Foundation
import UIKit
import TVUIKit

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
        didSet {
            
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
    
    internal var titleText: String? {
        didSet {
            self.titleLabel.text = titleText
        }
      }
      
      /// public property to store the text for the title image
      internal var titleImage: UIImage! {
        didSet {
            self.cameraImageView.image = titleImage
        }
      }
    
    fileprivate var posterView:TVPosterView!
    
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
    
    /*override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if context.nextFocusedView == self {
              UIView.animate(withDuration: 0.2, animations: {
                self.titleLabel.isHidden = true
                //self.titleLabel.transform = self.titleLabel.transform.scaledBy(x: self.scaleFactor, y: self.scaleFactor)
                //self.titleLabel.contentScaleFactor = self.scaleFactor
              })
            } else {
              UIView.animate(withDuration: 0.2) {
                self.titleLabel.isHidden = false
                //self.titleLabel.transform = CGAffineTransform.identity
              }
            }
    }*/
    
    internal func setupUI()
    {
        //self.cameraImageView = UIImageView()
        //self.titleLabel = UILabel()
        
        cameraImageView = UIImageView()
        titleLabel = UILabel()
        
        stream = MJPEGStreamLib(imageView: cameraImageView)
        //addSubview(posterView)
        //posterView.alignToSuperView()
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
