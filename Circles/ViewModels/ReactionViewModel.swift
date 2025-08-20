//
//  ReactionViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI
import Foundation
import FirebaseFirestore

@MainActor
class ReactionViewModel: ObservableObject {
    
    let firestoreManager: FirestoreManager
    
    @Published var reactions: [Reaction] = []
    @Published var visibleReactions: Set<String> = []
    private var isSelected: Bool = false
    private var listener: ListenerRegistration?
    
    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        if selected {
            animateIn(reactions)
        } else {
            visibleReactions.removeAll()
        }
    }
        
    private func handleReactionChange(newReactions: [Reaction]) {
        self.reactions = newReactions
        
        guard isSelected else {
            visibleReactions.removeAll()
            return
        }
        
        let newIDs = Set(newReactions.compactMap { $0.id })
        let oldIDs = visibleReactions
        
        // Added
        let added = newIDs.subtracting(oldIDs)
        for (idx, id) in added.enumerated() {
            let delay = Double(idx) * 0.15
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.visibleReactions.insert(id)
            }
        }
        
        // Removed
        let removed = oldIDs.subtracting(newIDs)
        for (idx, id) in removed.enumerated() {
            let delay = Double(idx) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.visibleReactions.remove(id)
            }
        }
    }
    
    private func animateIn(_ reactions: [Reaction]) {
        for (idx, emote) in reactions.enumerated() {
            if let id = emote.id {
                let delay = Double(idx) * 0.15
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.visibleReactions.insert(id)
                }
            }
        }
    }
    
    func listenForReactions(username: String, date: Date) async {
        stopListening()
        
        guard let userID = try? await firestoreManager.usernameToUID(username: username), !userID.isEmpty else {
            print("Failed to get UID")
            return
        }
        
        let moodId = DailyMood.dateId(from: date)
        guard !moodId.isEmpty else {
            print("Mood ID is empty")
            return
        }
        let db = Firestore.firestore()
        
        listener = db
            .collection("users")
            .document(userID)
            .collection("dailyMoods")
            .document(moodId)
            .collection("reactions")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self, let docs = snapshot?.documents else { return }
                
                self.reactions = docs.compactMap { doc in
                    var reaction = try? doc.data(as: Reaction.self)
                    reaction?.id = doc.documentID
                    return reaction
                }
            }
        
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
