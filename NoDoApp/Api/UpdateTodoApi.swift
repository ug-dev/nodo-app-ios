//
//  UpdateTodoApi.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 25/01/22.
//

import Foundation

func updateTodoApi(isDone: Bool, id: Int, title: String) {
    guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/updateTodo/\(id)/") else {return}
    var request = URLRequest(url: url)
    
    print("making api call....")
    print("🚀Title \(title)")
    print("🚀isDone \(isDone)")
    
    //method headers
    request.httpMethod = "PATCH"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: AnyHashable] = [
        "title": title,
        "isDone": isDone,
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) {data, _, error in
        guard let data = data, error == nil else {
            return
        }
        
        let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
        print("🚀🚀🚀🚀 Todo Updated: \(dataList)")
    }
    task.resume()
}
