//
//  ContentView.swift
//  lify
//
//  Created by Gergo Csizmadia on 2023. 03. 12..
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    var userId: String
    
    var listManager: ListManager
    
    init(userId: String){
        self.userId = userId
        self.listManager = ListManager(userId: self.userId)
    }
    
    var body: some View {
        if(self.userId == ""){
            AuthView()
        }
        else{
            MainView()
                .environmentObject(listManager)
        }
       
    }
}
