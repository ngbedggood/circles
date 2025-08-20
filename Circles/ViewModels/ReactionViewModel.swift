//
//  ReactionViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ReactionViewModel: ObservableObject {
    
    let firestoreManager: FirestoreManager
    
    @Published var currentUserEmote: String?
    @Published var reactions: [Reaction] = []
    @Published var visibleReactions: Set<String> = []
    @Published var showEmotePicker: Bool = false
    private var isSelected: Bool = false
    private var listener: ListenerRegistration?
    
    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }
    
    func reactToFriendMood(friend: FriendColor, date: Date) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let emote = currentUserEmote else { return }

        if emote == "" {
            do {
                let friendID = try await firestoreManager.usernameToUID(username: friend.username)
                try await firestoreManager.removeReact(fromUID: userID, toUID: friendID, date: date)
            } catch {
                print("Error removing reaction:", error)
            }
        } else {
            do {
                let friendID = try await firestoreManager.usernameToUID(username: friend.username)
                try await firestoreManager.emoteReactToFriendsPost(
                    date: Date(),
                    fromUID: userID,
                    toUID: friendID,
                    emote: emote
                )
            } catch {
                print("Error reacting to friend's mood:", error)
            }
        }
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        if selected {
            animateIn(reactions)
        } else {
            withAnimation {
                visibleReactions.removeAll()
            }
        }
    }
        
    private func handleReactionChange(newReactions: [Reaction]) {
        self.reactions = newReactions
        
        guard isSelected else {
            withAnimation {
                visibleReactions.removeAll()
            }
            return
        }
        
        let newIDs = Set(newReactions.compactMap { $0.id })
        let oldIDs = visibleReactions
        
        // Added
        let added = newIDs.subtracting(oldIDs)
        for (idx, id) in added.enumerated() {
            let delay = Double(idx) * 0.15 + 0.45
            withAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.visibleReactions.insert(id)
                }
            }
        }
        
        // Removed
        let removed = oldIDs.subtracting(newIDs)
        for (idx, id) in removed.enumerated() {
            let delay = Double(idx) * 0.1
            withAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.visibleReactions.remove(id)
                }
            }
        }
    }
    
    private func animateIn(_ reactions: [Reaction]) {
        for (idx, emote) in reactions.enumerated() {
            if let id = emote.id {
                let delay = Double(idx) * 0.15 + 0.45
                withAnimation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.visibleReactions.insert(id)
                    }
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
                
                // Update the current user's emote
                if let myUID = Auth.auth().currentUser?.uid {
                    withAnimation {
                        self.currentUserEmote = self.reactions.first { $0.id == myUID }?.reaction
                    }
                }
            }
        
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
