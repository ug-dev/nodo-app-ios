//
//  MyTodoData.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 25/01/22.
//

import Foundation

class MyTodoData: ObservableObject {
    @Published var id = 0
    @Published var title = "some text"
    @Published var description = "some text"
    @Published var date = "some text"
    @Published var isDone = false
}
