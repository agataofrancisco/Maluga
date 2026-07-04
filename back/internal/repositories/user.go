package repositories

import (
	"database/sql"
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/maluga/back/internal/models"
)

type UserRepository struct {
	db *sqlx.DB
}

func NewUserRepository(db *sqlx.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(u *models.User) error {
	query := `INSERT INTO users (name, email, password_hash, phone, nif, location, role)
	          VALUES ($1, $2, $3, $4, $5, $6, $7)
	          RETURNING id, created_at`
	return r.db.QueryRowx(query, u.Name, u.Email, u.PasswordHash, u.Phone, u.NIF, u.Location, u.Role).
		Scan(&u.ID, &u.CreatedAt)
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	var u models.User
	err := r.db.Get(&u, `SELECT id, name, email, password_hash, phone, nif, location, role, created_at
	                     FROM users WHERE email = $1`, email)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get user by email: %w", err)
	}
	return &u, nil
}

func (r *UserRepository) GetByID(id int64) (*models.User, error) {
	var u models.User
	err := r.db.Get(&u, `SELECT id, name, email, password_hash, phone, nif, location, role, created_at
	                     FROM users WHERE id = $1`, id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("get user by id: %w", err)
	}
	return &u, nil
}
