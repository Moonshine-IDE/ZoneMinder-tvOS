//
//  CameraItemVO.swift
//  ZoneMinder
//
//  Created by Devsena on 13/12/22.
//

import Foundation

struct CameraItemVO:Decodable
{
    let name:String!
    let message:String!
    let entries:[String]!
    let critical:Bool!
    
    func alertTitle() -> String {
        return name + " (" + ((message != nil) ? message : "") + ")"
    }
}
