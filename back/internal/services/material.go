package services

import (
	"errors"
	"fmt"

	"github.com/maluga/back/internal/models"
	"github.com/maluga/back/internal/repositories"
)

type MaterialService struct {
	repo *repositories.MaterialRepository
}

func NewMaterialService(repo *repositories.MaterialRepository) *MaterialService {
	return &MaterialService{repo: repo}
}

func (s *MaterialService) Create(ownerID int64, req *models.MaterialCreateRequest) (*models.Material, error) {
	m := &models.Material{
		OwnerID:     ownerID,
		Name:        req.Name,
		Description: req.Description,
		Quantity:    req.Quantity,
		Status:      req.Status,
		Price:       req.Price,
		ImageURL:    req.ImageURL,
	}
	if err := s.repo.Create(m); err != nil {
		return nil, fmt.Errorf("create material: %w", err)
	}
	return m, nil
}

func (s *MaterialService) GetByID(id int64) (*models.Material, error) {
	m, err := s.repo.GetByID(id)
	if err != nil {
		return nil, fmt.Errorf("get material: %w", err)
	}
	if m == nil {
		return nil, errors.New("material not found")
	}
	return m, nil
}

func (s *MaterialService) List(page, pageSize int) ([]models.Material, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	return s.repo.List(pageSize, offset)
}

func (s *MaterialService) Search(req *models.MaterialSearchRequest, page, pageSize int) ([]models.Material, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize
	return s.repo.Search(req, pageSize, offset)
}

func (s *MaterialService) Update(ownerID int64, id int64, req *models.MaterialUpdateRequest) (*models.Material, error) {
	m, err := s.repo.GetByID(id)
	if err != nil {
		return nil, fmt.Errorf("get material: %w", err)
	}
	if m == nil {
		return nil, errors.New("material not found")
	}
	if m.OwnerID != ownerID {
		return nil, errors.New("unauthorized: not the owner")
	}

	if req.Name != nil {
		m.Name = *req.Name
	}
	if req.Description != nil {
		m.Description = *req.Description
	}
	if req.Quantity != nil {
		m.Quantity = *req.Quantity
	}
	if req.Status != nil {
		m.Status = *req.Status
	}
	if req.Price != nil {
		m.Price = *req.Price
	}
	if req.ImageURL != nil {
		m.ImageURL = *req.ImageURL
	}

	if err := s.repo.Update(m); err != nil {
		return nil, fmt.Errorf("update material: %w", err)
	}
	return m, nil
}

func (s *MaterialService) Delete(ownerID, id int64) error {
	m, err := s.repo.GetByID(id)
	if err != nil {
		return fmt.Errorf("get material: %w", err)
	}
	if m == nil {
		return errors.New("material not found")
	}
	if m.OwnerID != ownerID {
		return errors.New("unauthorized: not the owner")
	}
	return s.repo.Delete(id, ownerID)
}
