//
//  AddTodoApi.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 25/01/22.
//

import Foundation

func addTodoApi(todo: String) {
    var globalListState = GlobalListState()
    guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/createTodo/") else {return}
    var request = URLRequest(url: url)
    
    print("making api call....")
    
    //method headers
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: AnyHashable] = [
        "title": todo,
        "description": "",
        "isDone": false,
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) {data, _, error in
        guard let data = data, error == nil else {
            return
        }
        
        let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
        print("🚀🚀🚀🚀 Todo Added: \(dataList)")
        globalListState.loading = false
    }
    task.resume()
}

