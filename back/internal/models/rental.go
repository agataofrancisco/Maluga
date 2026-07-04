package models

import "time"

type Rental struct {
	ID         int64     `db:"id" json:"id"`
	OwnerID    int64     `db:"owner_id" json:"owner_id"`
	RenterID   int64     `db:"renter_id" json:"renter_id"`
	MaterialID int64     `db:"material_id" json:"material_id"`
	Quantity   int       `db:"quantity" json:"quantity"`
	StartDate  time.Time `db:"start_date" json:"start_date"`
	EndDate    time.Time `db:"end_date" json:"end_date"`
	Total      float64   `db:"total" json:"total"`
	Status     string    `db:"status" json:"status"`
	CreatedAt  time.Time `db:"created_at" json:"created_at"`
	UpdatedAt  time.Time `db:"updated_at" json:"updated_at"`

	MaterialName string `db:"material_name" json:"material_name,omitempty"`
	OwnerName    string `db:"owner_name" json:"owner_name,omitempty"`
	RenterName   string `db:"renter_name" json:"renter_name,omitempty"`
}

type RentalCreateRequest struct {
	MaterialID int64     `json:"material_id" binding:"required"`
	Quantity   int       `json:"quantity" binding:"required,min=1"`
	StartDate  time.Time `json:"start_date" binding:"required"`
	EndDate    time.Time `json:"end_date" binding:"required"`
}

type RentalFilter struct {
	Role   string `form:"role"`
	Status string `form:"status"`
}
