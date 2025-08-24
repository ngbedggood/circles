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
    
    // Toast related
    @Published var showToast: Bool = false
    @Published private(set) var toastMessage: String = ""
    @Published private(set) var toastStyle: ToastStyle = .success
    
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
    func showLockedToast() {
        self.showToast = false
        self.toastMessage = "Reacting to past mood entries is locked."
        self.toastStyle = .warning
        self.showToast = true
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
            
        guard let friendUID = try? await firestoreManager.usernameToUID(username: username) else {
            print("Failed to get UID")
            return
        }
        
        guard let moodId = try? await firestoreManager.findFriendMoodDocumentID(forViewerDate: date, friendUID: friendUID) else {
            print("No mood document found for \(username) on \(date) from the viewer's perspective.")
            // Clear out any existing reactions since there's no mood to react to.
            self.reactions = []
            return
        }
        
        let db = Firestore.firestore()

        listener = db
            .collection("users")
            .document(friendUID)
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
        
        print("For user \(username) on \(date), started listening for reactions. Mood ID is \(moodId)")
        
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
