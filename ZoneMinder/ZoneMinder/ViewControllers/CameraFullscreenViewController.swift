//
//  CameraFullscreenViewController.swift
//  ZoneMinder
//
//  Created by Devsena on 21/12/22.
//

import Foundation
import UIKit

class CameraFullscreenViewController:UIViewController
{
    @IBOutlet weak var imgCamera: UIImageView!
    
    var camera:CameraItemVO!
    
    fileprivate var stream:MJPEGStreamLib!
    fileprivate var spinner:UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        stream = MJPEGStreamLib(imageView: imgCamera)
        
        stream.didStartLoading = { [unowned self] in
            self.updateSpinnerView(show: true)
        }
        stream.didFinishLoading = { [unowned self] in
            self.updateSpinnerView(show: false)
        }
        
        let url = URL(string:"https://zm-node-s2-01.prominic.net/zm/cgi-bin/nph-zms?scale=0&mode=jpeg&maxfps=30&monitor=90&user=Prominic&connkey=683812&rand=16666303660")
        stream.contentURL = url
        stream.play()
    }
    
    fileprivate func updateSpinnerView(show:Bool)
    {
        if (show)
        {
            spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = UIColor.darkGray
            view.addSubview(spinner)

            spinner.translatesAutoresizingMaskIntoConstraints = false
            
            spinner.centerXAnchor.constraint(equalTo: (view.centerXAnchor)).isActive = true
            spinner.centerYAnchor.constraint(equalTo: (view.centerYAnchor)).isActive = true
            spinner.startAnimating()
        }
        else if (!show)
        {
            DispatchQueue.main.async{
                self.spinner.stopAnimating()
                self.view.willRemoveSubview(self.spinner)
            }
        }
    }
}
