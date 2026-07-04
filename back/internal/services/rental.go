package services

import (
	"errors"
	"fmt"

	"github.com/maluga/back/internal/models"
	"github.com/maluga/back/internal/repositories"
)

type RentalService struct {
	rentalRepo   *repositories.RentalRepository
	materialRepo *repositories.MaterialRepository
}

func NewRentalService(rentalRepo *repositories.RentalRepository) *RentalService {
	return &RentalService{rentalRepo: rentalRepo}
}

func (s *RentalService) SetMaterialRepo(materialRepo *repositories.MaterialRepository) {
	s.materialRepo = materialRepo
}

func (s *RentalService) Create(renterID int64, req *models.RentalCreateRequest) (*models.Rental, error) {
	material, err := s.materialRepo.GetByID(req.MaterialID)
	if err != nil {
		return nil, fmt.Errorf("get material: %w", err)
	}
	if material == nil {
		return nil, errors.New("material not found")
	}
	if material.OwnerID == renterID {
		return nil, errors.New("cannot rent your own material")
	}
	if material.Quantity < req.Quantity {
		return nil, errors.New("insufficient quantity available")
	}

	days := int(req.EndDate.Sub(req.StartDate).Hours() / 24)
	if days <= 0 {
		days = 1
	}
	total := material.Price * float64(req.Quantity) * float64(days)

	rental := &models.Rental{
		OwnerID:    material.OwnerID,
		RenterID:   renterID,
		MaterialID: req.MaterialID,
		Quantity:   req.Quantity,
		StartDate:  req.StartDate,
		EndDate:    req.EndDate,
		Total:      total,
	}

	if err := s.rentalRepo.Create(rental); err != nil {
		return nil, fmt.Errorf("create rental: %w", err)
	}

	if err := s.materialRepo.DecreaseQuantity(req.MaterialID, req.Quantity); err != nil {
		return nil, fmt.Errorf("decrease stock: %w", err)
	}

	return rental, nil
}

func (s *RentalService) ListMine(userID int64, role string) ([]models.Rental, error) {
	return s.rentalRepo.ListByUserID(userID, role)
}

func (s *RentalService) MarkReturned(userID, rentalID int64) error {
	rental, err := s.rentalRepo.GetByID(rentalID)
	if err != nil {
		return fmt.Errorf("get rental: %w", err)
	}
	if rental == nil {
		return errors.New("rental not found")
	}
	if rental.OwnerID != userID {
		return errors.New("unauthorized: not the owner")
	}
	if rental.Status == "returned" {
		return errors.New("rental already returned")
	}

	if err := s.rentalRepo.MarkReturned(rentalID); err != nil {
		return fmt.Errorf("mark returned: %w", err)
	}

	if err := s.materialRepo.IncreaseQuantity(rental.MaterialID, rental.Quantity); err != nil {
		return fmt.Errorf("restore stock: %w", err)
	}
	return nil
}

func (s *RentalService) ListOverdue() ([]models.Rental, error) {
	return s.rentalRepo.ListOverdue()
}
