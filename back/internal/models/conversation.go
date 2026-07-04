package models

import "time"

type Conversation struct {
	ID         int64     `db:"id" json:"id"`
	MaterialID int64     `db:"material_id" json:"material_id"`
	OwnerID    int64     `db:"owner_id" json:"owner_id"`
	RenterID   int64     `db:"renter_id" json:"renter_id"`
	CreatedAt  time.Time `db:"created_at" json:"created_at"`

	MaterialName string `db:"material_name" json:"material_name,omitempty"`
	OwnerName    string `db:"owner_name" json:"owner_name,omitempty"`
	RenterName   string `db:"renter_name" json:"renter_name,omitempty"`
}

type Message struct {
	ID             int64     `db:"id" json:"id"`
	ConversationID int64     `db:"conversation_id" json:"conversation_id"`
	SenderID       int64     `db:"sender_id" json:"sender_id"`
	Content        string    `db:"content" json:"content"`
	Read           bool      `db:"read" json:"read"`
	CreatedAt      time.Time `db:"created_at" json:"created_at"`

	SenderName string `db:"sender_name" json:"sender_name,omitempty"`
}

type ConversationCreateRequest struct {
	MaterialID int64 `json:"material_id" binding:"required"`
}

type WSMessage struct {
	Type            string `json:"type"`
	ConversationID  int64  `json:"conversation_id"`
	SenderID        int64  `json:"sender_id"`
	Content         string `json:"content"`
}
