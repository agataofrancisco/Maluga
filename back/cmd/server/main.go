package main

import (
	"log"

	"github.com/maluga/back/internal/config"
	"github.com/maluga/back/internal/handlers"
	"github.com/maluga/back/internal/middleware"
	"github.com/maluga/back/internal/repositories"
	"github.com/maluga/back/internal/services"
	"github.com/maluga/back/internal/ws"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	_ "github.com/jackc/pgx/v5/stdlib"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	db, err := sqlx.Connect("pgx", cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer db.Close()

	if err := repositories.RunMigrations(db); err != nil {
		log.Fatalf("failed to run migrations: %v", err)
	}

	userRepo := repositories.NewUserRepository(db)
	materialRepo := repositories.NewMaterialRepository(db)
	rentalRepo := repositories.NewRentalRepository(db)
	convRepo := repositories.NewConversationRepository(db)
	msgRepo := repositories.NewMessageRepository(db)

	authService := services.NewAuthService(userRepo, cfg.JWTSecret)
	materialService := services.NewMaterialService(materialRepo)
	rentalService := services.NewRentalService(rentalRepo)
	rentalService.SetMaterialRepo(materialRepo)
	chatService := services.NewChatService(convRepo, msgRepo)

	hub := ws.NewHub()
	go hub.Run()

	r := gin.Default()
	r.Use(middleware.CORS())

	api := r.Group("/api")
	{
		auth := handlers.NewAuthHandler(authService)
		api.POST("/auth/register", auth.Register)
		api.POST("/auth/login", auth.Login)

		material := handlers.NewMaterialHandler(materialService)
		api.GET("/materials", material.List)
		api.GET("/materials/:id", material.GetByID)
		api.GET("/materials/search", material.Search)

		protected := api.Group("")
		protected.Use(middleware.AuthRequired(cfg.JWTSecret))
		{
			protected.POST("/materials", material.Create)
			protected.PUT("/materials/:id", material.Update)
			protected.DELETE("/materials/:id", material.Delete)

			rental := handlers.NewRentalHandler(rentalService)
			protected.GET("/rentals", rental.ListMine)
			protected.POST("/rentals", rental.Create)
			protected.PATCH("/rentals/:id/return", rental.MarkReturned)

			chat := handlers.NewChatHandler(chatService)
			protected.GET("/conversations", chat.ListConversations)
			protected.GET("/conversations/:id/messages", chat.GetMessages)
			protected.POST("/conversations", chat.StartConversation)

			protected.GET("/ws", func(c *gin.Context) {
				ws.ServeWS(hub, c.Writer, c.Request)
			})
		}
	}

	log.Printf("Maluga backend starting on :%s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
