package repositories

import (
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/maluga/back/internal/models"
)

type MaterialRepository struct {
	db *sqlx.DB
}

func NewMaterialRepository(db *sqlx.DB) *MaterialRepository {
	return &MaterialRepository{db: db}
}

func (r *MaterialRepository) Create(m *models.Material) error {
	query := `INSERT INTO materials (owner_id, name, description, quantity, status, price, image_url)
	          VALUES ($1, $2, $3, $4, $5, $6, $7)
	          RETURNING id, created_at, updated_at`
	return r.db.QueryRowx(query, m.OwnerID, m.Name, m.Description, m.Quantity, m.Status, m.Price, m.ImageURL).
		Scan(&m.ID, &m.CreatedAt, &m.UpdatedAt)
}

func (r *MaterialRepository) GetByID(id int64) (*models.Material, error) {
	var m models.Material
	err := r.db.Get(&m, `SELECT id, owner_id, name, description, quantity, status, price, image_url, created_at, updated_at
	                     FROM materials WHERE id = $1`, id)
	if err != nil {
		return nil, fmt.Errorf("get material: %w", err)
	}
	return &m, nil
}

func (r *MaterialRepository) List(limit, offset int) ([]models.Material, error) {
	var materials []models.Material
	err := r.db.Select(&materials, `SELECT id, owner_id, name, description, quantity, status, price, image_url, created_at, updated_at
	                                FROM materials ORDER BY created_at DESC LIMIT $1 OFFSET $2`, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list materials: %w", err)
	}
	return materials, nil
}

func (r *MaterialRepository) ListByOwner(ownerID int64) ([]models.Material, error) {
	var materials []models.Material
	err := r.db.Select(&materials, `SELECT id, owner_id, name, description, quantity, status, price, image_url, created_at, updated_at
	                                FROM materials WHERE owner_id = $1 ORDER BY created_at DESC`, ownerID)
	if err != nil {
		return nil, fmt.Errorf("list materials by owner: %w", err)
	}
	return materials, nil
}

func (r *MaterialRepository) Search(req *models.MaterialSearchRequest, limit, offset int) ([]models.Material, error) {
	var materials []models.Material
	query := `SELECT id, owner_id, name, description, quantity, status, price, image_url, created_at, updated_at
	          FROM materials WHERE 1=1`
	args := []interface{}{}
	argIdx := 1

	if req.Query != "" {
		query += fmt.Sprintf(" AND (name ILIKE $%d OR description ILIKE $%d)", argIdx, argIdx)
		args = append(args, "%"+req.Query+"%")
		argIdx++
	}
	if req.Status != "" {
		query += fmt.Sprintf(" AND status = $%d", argIdx)
		args = append(args, req.Status)
		argIdx++
	}
	if req.MinPrice > 0 {
		query += fmt.Sprintf(" AND price >= $%d", argIdx)
		args = append(args, req.MinPrice)
		argIdx++
	}
	if req.MaxPrice > 0 {
		query += fmt.Sprintf(" AND price <= $%d", argIdx)
		args = append(args, req.MaxPrice)
		argIdx++
	}
	query += fmt.Sprintf(" ORDER BY created_at DESC LIMIT $%d OFFSET $%d", argIdx, argIdx+1)
	args = append(args, limit, offset)

	err := r.db.Select(&materials, query, args...)
	if err != nil {
		return nil, fmt.Errorf("search materials: %w", err)
	}
	return materials, nil
}

func (r *MaterialRepository) Update(m *models.Material) error {
	query := `UPDATE materials SET name = $1, description = $2, quantity = $3, status = $4, price = $5, image_url = $6, updated_at = NOW()
	          WHERE id = $7 AND owner_id = $8 RETURNING updated_at`
	return r.db.QueryRowx(query, m.Name, m.Description, m.Quantity, m.Status, m.Price, m.ImageURL, m.ID, m.OwnerID).
		Scan(&m.UpdatedAt)
}

func (r *MaterialRepository) Delete(id, ownerID int64) error {
	_, err := r.db.Exec(`DELETE FROM materials WHERE id = $1 AND owner_id = $2`, id, ownerID)
	if err != nil {
		return fmt.Errorf("delete material: %w", err)
	}
	return nil
}

func (r *MaterialRepository) DecreaseQuantity(id int64, qty int) error {
	_, err := r.db.Exec(`UPDATE materials SET quantity = quantity - $1, updated_at = NOW()
	                     WHERE id = $2 AND quantity >= $1`, qty, id)
	if err != nil {
		return fmt.Errorf("decrease quantity: %w", err)
	}
	return nil
}

func (r *MaterialRepository) IncreaseQuantity(id int64, qty int) error {
	_, err := r.db.Exec(`UPDATE materials SET quantity = quantity + $1, updated_at = NOW()
	                     WHERE id = $2`, qty, id)
	if err != nil {
		return fmt.Errorf("increase quantity: %w", err)
	}
	return nil
}
