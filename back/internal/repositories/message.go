package repositories

import (
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/maluga/back/internal/models"
)

type MessageRepository struct {
	db *sqlx.DB
}

func NewMessageRepository(db *sqlx.DB) *MessageRepository {
	return &MessageRepository{db: db}
}

func (r *MessageRepository) Create(msg *models.Message) error {
	query := `INSERT INTO messages (conversation_id, sender_id, content)
	          VALUES ($1, $2, $3)
	          RETURNING id, read, created_at`
	return r.db.QueryRowx(query, msg.ConversationID, msg.SenderID, msg.Content).
		Scan(&msg.ID, &msg.Read, &msg.CreatedAt)
}

func (r *MessageRepository) ListByConversation(convID int64) ([]models.Message, error) {
	var msgs []models.Message
	err := r.db.Select(&msgs, `SELECT m.id, m.conversation_id, m.sender_id, m.content, m.read, m.created_at,
	                                  u.name AS sender_name
	                           FROM messages m
	                           JOIN users u ON m.sender_id = u.id
	                           WHERE m.conversation_id = $1
	                           ORDER BY m.created_at ASC`, convID)
	if err != nil {
		return nil, fmt.Errorf("list messages: %w", err)
	}
	return msgs, nil
}

func (r *MessageRepository) MarkAsRead(convID, userID int64) error {
	_, err := r.db.Exec(`UPDATE messages SET read = TRUE
	                     WHERE conversation_id = $1 AND sender_id != $2 AND read = FALSE`, convID, userID)
	if err != nil {
		return fmt.Errorf("mark as read: %w", err)
	}
	return nil
}
