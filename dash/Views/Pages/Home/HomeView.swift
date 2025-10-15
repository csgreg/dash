//
//  HomeView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 18.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import RiveRuntime

struct HomeView: View {
    @EnvironmentObject var listManager: ListManager
    
    var body: some View {
        NavigationView{
                ZStack{
                    ScrollView {
                        ForEach(listManager.lists) { list in
                            NavigationLink{
                                ListDetailsView(list: list)
                            } label: {
                                ListButton(text: list.name, allItems: list.items.count, completedItems: list.items.filter({$0.done}).count, sharedWith: list.users.count ).transition(.slide).padding(.horizontal)
                            }.simultaneousGesture(TapGesture().onEnded{
                                listManager.setSelectedList(listId:list.id)
                            })
                        }
                    }
                }.navigationTitle("Lists")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ListManager(userId: "asd"))
    }
}
