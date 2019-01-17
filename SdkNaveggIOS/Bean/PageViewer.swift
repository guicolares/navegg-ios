//
//  PageView.swift
//  SdkNavegg
//
//  Created by Navegg on 12/12/17.
//  Copyright © 2017 Navegg. All rights reserved.
//

import Foundation

struct PageViewer : Encodable, Decodable {
    var view : String
    var dateTime : Int64
    var titlePage : String
    var callPage : String
}
