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
    
    fileprivate var detailView:UIView!
    {
        didSet
        {
            detailView.backgroundColor = UIColor(red: 20/155, green: 106/255, blue: 96/195, alpha: 0.5)
            addSubview(detailView)
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
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        detailView.leadingAnchor.constraint(equalTo: cameraImageView.leadingAnchor, constant: 0).isActive = true
        detailView.trailingAnchor.constraint(equalTo: cameraImageView.trailingAnchor, constant: 0).isActive = true
        detailView.topAnchor.constraint(equalTo: cameraImageView.topAnchor, constant: 150).isActive = true
        detailView.bottomAnchor.constraint(equalTo: cameraImageView.bottomAnchor, constant: 0).isActive = true
        detailView.contentScaleFactor = cameraImageView.contentScaleFactor
        
        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if context.nextFocusedView == self
        {
            UIView.animate(withDuration: 0.1, animations: { [self] in
                self.titleLabel.isHidden = true
                self.detailView.transform = self.detailView.transform.scaledBy(x: 1.185, y: 1.185)
                self.detailView.contentScaleFactor = 1.185
            })
        }
        else
        {
            UIView.animate(withDuration: 0.1) {
                self.titleLabel.isHidden = false
                self.detailView.transform = CGAffineTransform.identity
            }
        }
    }

    internal func setupUI()
    {
        cameraImageView = UIImageView()
        titleLabel = UILabel()
        detailView = UIView()
        
        
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
