//
//  TodoDataModel.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 20/01/22.
//

//"id": 1,
//            "title": "first artical",
//            "description": "Hello from shubham",
//            "date": "2022-01-17",
//            "isDone": false

import Foundation

struct TodoDataModel: Decodable, Identifiable {
    var id: Int
    var title: String
    var description: String
    var date: String
    var isDone: Bool
}


//struct TodoDataModel: Decodable, Identifiable {
//    var userId: Int
//    var id: Int
//    var title: String
//    var body: String
//}



