//
//  ContentView.swift
//  NoDoApp
//
//  Created by Umang Gadhavana on 17/01/22.
//

import SwiftUI
import ActivityIndicatorView

struct ContentView: View {
    @StateObject var todoDataItem = MyTodoData()
    @State var globalListState = GlobalListState()
    @State var nodoList = [TodoDataModel]()
    @State var showModel = false
    @State var editNodo = ""
    @State var nodo: String = ""

    
    func fetchTodos() {
        guard let url = URL(string: "https://todo-python-heroku.herokuapp.com/") else {return}
        print("okay fetch fuck")
        URLSession.shared
            .dataTask(with: url) {
                (data, _, _) in
                guard let data = data else {return}

                let dataList = try! JSONDecoder().decode([TodoDataModel].self, from: data)
                print("🚀🚀🚀🚀 fetch \(dataList)")

                DispatchQueue.main.async {
                    nodoList = dataList
                    globalListState.loading = false
                    print("🚀🚀🚀🚀 nodoList \(nodoList)")
                }
            }.resume()
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    HStack{
                    Image(systemName: "plus.circle")
                  
                    Group{
                        TextField(
                                "What will you not do today",
                                text: self.$nodo
                        )
                            .foregroundColor(.white)
                            .onSubmit {
                                if (nodo != "") {
                                    print("🚀🚀🚀🚀okay \(nodo)")
                                    globalListState.loading = true
                                    addTodoApi(todo: self.nodo)
                                    fetchTodos()
                                    self.nodo = ""
                                } else {
                                    print("No Bitch!")
                                }
                                
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
                        ForEach(nodoList) { item in
                            NodoRow(Id: item.id, nodoItem: item.title,nodoToggle: item.isDone)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button(action: {
                                            // edit
                                            todoDataItem.id = item.id
                                            todoDataItem.title = item.title
                                            todoDataItem.description = item.description
                                            todoDataItem.date = item.date
                                            todoDataItem.isDone = item.isDone
                                            print("🚀ID: \(item.id)")
                                            showModel = true
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                        }
                                        .tint(.blue)
                                    }
                                .swipeActions(allowsFullSwipe: true) {
                                    Button(action: {
                                        deleteTodo(todoDataModel: item)
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
                    
                    //Modal
                    if (showModel) {
                        ModalView(isShowing: $showModel, editNodo: $editNodo)
                    }
                    
            }
                .navigationBarTitle(Text("NoDo APP"))
        }
        .onAppear {
            fetchTodos()
        }
        }
        .environmentObject(todoDataItem)
    }
    
    func deleteTodo(todoDataModel: TodoDataModel) {
        if let indexToDelete = nodoList.firstIndex(where: {$0.id == todoDataModel.id}) {
            self.nodoList.remove(at: indexToDelete)
        }
    }
}
