//
//  URLDescriptorVO.swift
//  ZoneMinder
//
//  Created by Devsena on 20/01/23.
//

import Foundation

class URLDescriptorVO: NSObject
{
    static let BASE_URL = "http://127.0.0.1:8080/Cameras.nsf"
    
    static let GET_ALLOWED_TV_LIST = BASE_URL + "/AllowedTVRead?OpenAgent"
    static let GET_CAMERA_LIST = BASE_URL + "/CameraRead?OpenAgent"
}
