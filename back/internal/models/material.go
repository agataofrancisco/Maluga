package models

import "time"

type Material struct {
	ID          int64     `db:"id" json:"id"`
	OwnerID     int64     `db:"owner_id" json:"owner_id"`
	Name        string    `db:"name" json:"name"`
	Description string    `db:"description" json:"description"`
	Quantity    int       `db:"quantity" json:"quantity"`
	Status      string    `db:"status" json:"status"`
	Price       float64   `db:"price" json:"price"`
	ImageURL    string    `db:"image_url" json:"image_url"`
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
	UpdatedAt   time.Time `db:"updated_at" json:"updated_at"`
}

type MaterialCreateRequest struct {
	Name        string  `json:"name" binding:"required"`
	Description string  `json:"description" binding:"required"`
	Quantity    int     `json:"quantity" binding:"required,min=1"`
	Status      string  `json:"status" binding:"required,oneof=novo semi-novo antigo"`
	Price       float64 `json:"price" binding:"required,min=0"`
	ImageURL    string  `json:"image_url"`
}

type MaterialUpdateRequest struct {
	Name        *string  `json:"name"`
	Description *string  `json:"description"`
	Quantity    *int     `json:"quantity"`
	Status      *string  `json:"status"`
	Price       *float64 `json:"price"`
	ImageURL    *string  `json:"image_url"`
}

type MaterialSearchRequest struct {
	Query   string `form:"query"`
	Status  string `form:"status"`
	MinPrice float64 `form:"min_price"`
	MaxPrice float64 `form:"max_price"`
}
