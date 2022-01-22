//
//  ContentView.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 17/01/22.
//

import SwiftUI
import ActivityIndicatorView

struct GlobalListState {
    var loading = true
}

struct ContentView: View {
    @State var globalListState = GlobalListState()
    @State var nodoList = [TodoDataModel]()
    @State var nodo: String = ""
    @State private var showingAlert = false
    
    func fetchTodos() {
        guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/") else {return}
        print("okay")
        URLSession.shared
            .dataTask(with: url) {
                (data, _, _) in
                guard let data = data else {return}

                let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
                print("🚀🚀🚀🚀 fetch \(dataList)")

                DispatchQueue.main.async {
                    nodoList = dataList
                    globalListState.loading = false
                }
            }.resume()
    }
    
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Image(systemName: "plus.circle")
                        .alert("Important message", isPresented: $showingAlert) {
                                   Button("OK", role: .cancel) { }
                               }
                    Group{
                        TextField(
                                "What will you not do today",
                                text: self.$nodo
                        )
                            .foregroundColor(.white)
                            .onSubmit {
                                print("🚀🚀🚀🚀okay \(nodo)")
                                globalListState.loading = true
                                addTodoApi(todo: self.nodo)
                                fetchTodos()
                                self.nodo = ""
                            }
                            .padding(.all, 12)
                            .accessibilityIgnoresInvertColors()
                            
                    }.background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .shadow(radius: 4)
                }
                .padding(.horizontal, 14)
                
                if (globalListState.loading) {
                    ZStack {
                        ActivityIndicatorView(isVisible: $globalListState.loading, type: .default)
                        
                    }.frame(width: 20, height: 20).padding(.vertical, 28)
                }
                
                if (!globalListState.loading && nodoList.count == 0) {
                    HStack {
                        Text("No Data...")
                            .font(.title2)
                    }.padding(.top, 34)
                }
                    List {
                        ForEach(nodoList.reversed()) { item in
                            NodoRow(Id: item.id, nodoItem: item.title,nodoToggle: item.isDone)
//                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
//                                        Button(action: {
//                                            // edit
//                                        }) {
//                                            Image(systemName: "pencil.circle.fill")
//                                        }
//                                        .tint(.blue)
//                                    }
                                .swipeActions(allowsFullSwipe: true) {
                                    Button(action: {
                                        deleteTodo(tododDataModel: item)
                                        print("do something\(item.id)")
                                        deleteTodoApi(id: item.id)
                                    }) {
                                        Image(systemName: "trash.circle.fill")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                    .refreshable {
                        fetchTodos()
                    }
            }.navigationBarTitle(Text("NoDo APP"))
        }
        .onAppear {
            fetchTodos()
        }
    }
    
    func deleteTodo(tododDataModel: TodoDataModel) {
        if let indexToDelete = nodoList.firstIndex(where: {$0.id == tododDataModel.id}) {
            self.nodoList.remove(at: indexToDelete)
        }
    }
}

func addTodoApi(todo: String) {
    @State var globalListState = GlobalListState()
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
//        globalListState.nodoList = dataList
        globalListState.loading = false
    }
    task.resume()
}

func updateTodoApi(isDone: Bool, id: Int) {
    @State var globalListState = GlobalListState()
    guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/updateTodo/\(id)/") else {return}
    var request = URLRequest(url: url)
    
    print("making api call....")
    
    //method headers
    request.httpMethod = "PATCH"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: AnyHashable] = [
        "isDone": isDone,
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    
    let task = URLSession.shared.dataTask(with: request) {data, _, error in
        guard let data = data, error == nil else {
            return
        }
        
        let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
//        globalListState.nodoList = dataList
    }
    task.resume()
}

func deleteTodoApi(id: Int) {
    @State var globalListState = GlobalListState()
    guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/deleteTodo/\(id)/") else {return}
    var request = URLRequest(url: url)
    
    print("making api call....")
    
    //method headers
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) {data, _, error in
        guard let data = data, error == nil else {
            return
        }
        
        let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
//        globalListState.nodoList = dataList
    }
    task.resume()
}

struct NodoRow: View {
    @State var Id: Int
    @State var nodoItem: String = ""
    @State var nodoToggle: Bool = false
    
    var body: some View {
                HStack{
                    Text(nodoItem)
                        .strikethrough(self.nodoToggle, color:  Color.gray)
                        .foregroundColor(self.nodoToggle ? Color.gray : .accentColor)
                        .multilineTextAlignment(.leading)
                        .opacity(self.nodoToggle ? 0.4 : 1)
                        .lineLimit(2)
                        
                    Spacer()
                    Image(systemName:  (self.nodoToggle) ? "checkmark" : "square") //checkmark
                        .padding(.trailing, 4)
                }
                .padding(.vertical, 12)
                .cornerRadius(8)
                .lineSpacing(12)
                .onTapGesture {
                    print("🚀hello update \(!self.nodoToggle) \(Id)")
                    updateTodoApi(isDone: !self.nodoToggle, id: Id)
                    self.nodoToggle = !self.nodoToggle
                }
    }
}
