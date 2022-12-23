//
//  CameraItemVO.swift
//  ZoneMinder
//
//  Created by Devsena on 13/12/22.
//

import Foundation

struct CameraItemVO:Decodable
{
    let dominoUniversalID:String!
    let cameraID:String!
    let cameraName:String!
    var url:String!
    let frequency:Int!
    let group:String!
    let subGroup:String!
    
    var isStop = false
}
