package repositories

import (
	"database/sql"
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/maluga/back/internal/models"
)

type ConversationRepository struct {
	db *sqlx.DB
}

func NewConversationRepository(db *sqlx.DB) *ConversationRepository {
	return &ConversationRepository{db: db}
}

func (r *ConversationRepository) Create(conv *models.Conversation) error {
	query := `INSERT INTO conversations (material_id, owner_id, renter_id)
	          VALUES ($1, $2, $3)
	          ON CONFLICT (material_id, renter_id) DO UPDATE SET material_id = EXCLUDED.material_id
	          RETURNING id, created_at`
	return r.db.QueryRowx(query, conv.MaterialID, conv.OwnerID, conv.RenterID).
		Scan(&conv.ID, &conv.CreatedAt)
}

func (r *ConversationRepository) GetOrCreate(materialID, renterID int64) (*models.Conversation, error) {
	var m models.Material
	err := r.db.Get(&m, `SELECT id, owner_id FROM materials WHERE id = $1`, materialID)
	if err != nil {
		return nil, fmt.Errorf("material not found: %w", err)
	}

	conv := models.Conversation{
		MaterialID: materialID,
		OwnerID:    m.OwnerID,
		RenterID:   renterID,
	}
	err = r.Create(&conv)
	if err != nil {
		return nil, fmt.Errorf("create conversation: %w", err)
	}
	return &conv, nil
}

func (r *ConversationRepository) GetByID(id int64) (*models.Conversation, error) {
	var conv models.Conversation
	err := r.db.Get(&conv, `SELECT id, material_id, owner_id, renter_id, created_at
	                       FROM conversations WHERE id = $1`, id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get conversation: %w", err)
	}
	return &conv, nil
}

func (r *ConversationRepository) ListByUserID(userID int64) ([]models.Conversation, error) {
	var convs []models.Conversation
	err := r.db.Select(&convs, `SELECT c.id, c.material_id, c.owner_id, c.renter_id, c.created_at,
	                                  m.name AS material_name, ou.name AS owner_name, ru.name AS renter_name
	                           FROM conversations c
	                           JOIN materials m ON c.material_id = m.id
	                           JOIN users ou ON c.owner_id = ou.id
	                           JOIN users ru ON c.renter_id = ru.id
	                           WHERE c.owner_id = $1 OR c.renter_id = $1
	                           ORDER BY c.created_at DESC`, userID)
	if err != nil {
		return nil, fmt.Errorf("list conversations: %w", err)
	}
	return convs, nil
}

func (r *ConversationRepository) IsParticipant(convID, userID int64) (bool, error) {
	var exists bool
	err := r.db.Get(&exists, `SELECT EXISTS(SELECT 1 FROM conversations WHERE id = $1 AND (owner_id = $2 OR renter_id = $2))`,
		convID, userID)
	if err != nil {
		return false, fmt.Errorf("check participant: %w", err)
	}
	return exists, nil
}
