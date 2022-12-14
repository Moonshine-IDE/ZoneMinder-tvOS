//
//  TVItemVO.swift
//  ZoneMinder
//
//  Created by Devsena on 13/12/22.
//

import Foundation

struct TVItemVO:Decodable
{
    let name:String!
    let ID:String!
    let dominoUniversalID:String!
    let cameras:[String]!
}
