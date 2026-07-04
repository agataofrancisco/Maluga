package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/maluga/back/internal/models"
	"github.com/maluga/back/internal/services"
)

type RentalHandler struct {
	service *services.RentalService
}

func NewRentalHandler(service *services.RentalService) *RentalHandler {
	return &RentalHandler{service: service}
}

func (h *RentalHandler) Create(c *gin.Context) {
	var req models.RentalCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	renterID := c.GetInt64("user_id")
	rental, err := h.service.Create(renterID, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, rental)
}

func (h *RentalHandler) ListMine(c *gin.Context) {
	userID := c.GetInt64("user_id")
	role := c.DefaultQuery("role", "renter")

	rentals, err := h.service.ListMine(userID, role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"rentals": rentals})
}

func (h *RentalHandler) MarkReturned(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	userID := c.GetInt64("user_id")
	if err := h.service.MarkReturned(userID, id); err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "rental marked as returned"})
}
