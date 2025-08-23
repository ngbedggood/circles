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
    
    @Published var currentUserEmote: String = ""
    @Published var reactions: [Reaction] = []
    @Published var showEmotePicker: Bool = false
    private var isSelected: Bool = false
    private var listener: ListenerRegistration?
    
    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }
    
    func toggleSelection() {
        isSelected.toggle()
        if !isSelected {
            withAnimation {
                showEmotePicker = false
            }
        }
    }
    
    @MainActor
    func reactToFriendMood(friend: FriendColor, date: Date) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let emote = currentUserEmote

        do {
            let friendID = try await firestoreManager.usernameToUID(username: friend.username)

            // If the user already has a reaction locally
            if let oldReactionIndex = reactions.firstIndex(where: { $0.id == userID }) {
                // Remove it locally to trigger animation
                withAnimation {
                    reactions.remove(at: oldReactionIndex)
                }

                // Also remove from Firestore
                try await firestoreManager.softRemoveReact(fromUID: userID, toUID: friendID, date: date)

                // Wait for animation to finish before re-adding
                try await Task.sleep(nanoseconds: 300_000_000)
            }

            // If the new emote isn't empty, add it both locally + remotely
            if !emote.isEmpty {
                //let newReaction = Reaction(id: userID, reaction: emote)
                
//                withAnimation {
//                    reactions.append(newReaction)
//                }

                try await firestoreManager.emoteReactToFriendsPost(
                    date: date,
                    fromUID: userID,
                    toUID: friendID,
                    emote: emote
                )
            }

        } catch {
            print("Error reacting to friend's mood:", error)
        }
    }

    
    func listenForReactions(username: String, date: Date) async {
        stopListening()
        
        guard let userID = try? await firestoreManager.usernameToUID(username: username), !userID.isEmpty else {
            print("Failed to get UID")
            return
        }
        let moodId: String
        do {
            moodId = try await firestoreManager.userTZToMoodId(uid: userID, date: date)
        } catch {
            print(error.localizedDescription)
            return
        }
        
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
            .whereField("removed", isEqualTo: false) // only active reactions
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self, let docs = snapshot?.documents else { return }
                
                self.reactions = docs.compactMap { doc in
                    var reaction = try? doc.data(as: Reaction.self)
                    reaction?.id = doc.documentID
                    return reaction
                }
                
            }
        
    }
    
    func getCurrentUserEmote() {
        // Update the current user's emote
        if let myUID = Auth.auth().currentUser?.uid {
            withAnimation {
                self.currentUserEmote = self.reactions.first { $0.id == myUID }?.reaction ?? ""
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
