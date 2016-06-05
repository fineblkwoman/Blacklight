//
//  ChatViewController.swift
//  Blacklight
//
//  Created by Alicia MacBook Pro on 6/4/16.
//  Copyright © 2016 DiversityHack. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController


class ChatViewController: JSQMessagesViewController {
    
    
    let rootReference = FIRDatabase.database().referenceFromURL("https://blacklight-3aa59.firebaseio.com")
    var messageReference: FIRDatabaseReference!

    
    var messages = [JSQMessage]()
    
    var userIsTypingRef: FIRDatabaseReference!
    var usersTypingQuery: FIRDatabaseQuery!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Blacklight"
        setupBubbles()
        
        
        // no avatars 
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        messageReference = rootReference.child("messages")
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        observeMessages()
        observeTyping()
        

        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView

        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
        
    }
    
    private func observeMessages() {
        
        let messagesQuery = messageReference.queryLimitedToLast(25)
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
            
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String
            
            self.addMessage(id, text: text)
            
            self.finishReceivingMessage()
        }
        
    }
    
    private func observeTyping() {
         let typingIndicatorRef = rootReference.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersTypingQuery.observeEventType(.Value) { (data: FIRDataSnapshot!) in
            
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    
    override func textViewDidChange(textView: UITextView) {
        
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
        
    }
    
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageReference.childByAutoId()
        let messageItem = [ "text": text, "senderId": senderId]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        
        isTyping = false
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }


}
