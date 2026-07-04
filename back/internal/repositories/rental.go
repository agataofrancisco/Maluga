package repositories

import (
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/maluga/back/internal/models"
)

type RentalRepository struct {
	db *sqlx.DB
}

func NewRentalRepository(db *sqlx.DB) *RentalRepository {
	return &RentalRepository{db: db}
}

func (r *RentalRepository) Create(rental *models.Rental) error {
	query := `INSERT INTO rentals (owner_id, renter_id, material_id, quantity, start_date, end_date, total, status)
	          VALUES ($1, $2, $3, $4, $5, $6, $7, 'active')
	          RETURNING id, status, created_at, updated_at`
	return r.db.QueryRowx(query, rental.OwnerID, rental.RenterID, rental.MaterialID, rental.Quantity,
		rental.StartDate, rental.EndDate, rental.Total).
		Scan(&rental.ID, &rental.Status, &rental.CreatedAt, &rental.UpdatedAt)
}

func (r *RentalRepository) GetByID(id int64) (*models.Rental, error) {
	var rental models.Rental
	err := r.db.Get(&rental, `SELECT id, owner_id, renter_id, material_id, quantity, start_date, end_date, total, status, created_at, updated_at
	                          FROM rentals WHERE id = $1`, id)
	if err != nil {
		return nil, fmt.Errorf("get rental: %w", err)
	}
	return &rental, nil
}

func (r *RentalRepository) ListByUserID(userID int64, role string) ([]models.Rental, error) {
	var rentals []models.Rental
	var query string
	if role == "owner" {
		query = `SELECT r.id, r.owner_id, r.renter_id, r.material_id, r.quantity, r.start_date, r.end_date, r.total, r.status, r.created_at, r.updated_at,
		                m.name AS material_name, u.name AS renter_name
		         FROM rentals r
		         JOIN materials m ON r.material_id = m.id
		         JOIN users u ON r.renter_id = u.id
		         WHERE r.owner_id = $1 ORDER BY r.created_at DESC`
	} else {
		query = `SELECT r.id, r.owner_id, r.renter_id, r.material_id, r.quantity, r.start_date, r.end_date, r.total, r.status, r.created_at, r.updated_at,
		                m.name AS material_name, u.name AS owner_name
		         FROM rentals r
		         JOIN materials m ON r.material_id = m.id
		         JOIN users u ON r.owner_id = u.id
		         WHERE r.renter_id = $1 ORDER BY r.created_at DESC`
	}
	err := r.db.Select(&rentals, query, userID)
	if err != nil {
		return nil, fmt.Errorf("list rentals: %w", err)
	}
	return rentals, nil
}

func (r *RentalRepository) MarkReturned(id int64) error {
	_, err := r.db.Exec(`UPDATE rentals SET status = 'returned', updated_at = NOW() WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("mark returned: %w", err)
	}
	return nil
}

func (r *RentalRepository) ListOverdue() ([]models.Rental, error) {
	var rentals []models.Rental
	err := r.db.Select(&rentals, `SELECT id, owner_id, renter_id, material_id, quantity, start_date, end_date, total, status, created_at, updated_at
	                              FROM rentals WHERE status = 'active' AND end_date < NOW()`)
	if err != nil {
		return nil, fmt.Errorf("list overdue: %w", err)
	}
	return rentals, nil
}
