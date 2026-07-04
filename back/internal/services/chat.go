package services

import (
	"errors"
	"fmt"

	"github.com/maluga/back/internal/models"
	"github.com/maluga/back/internal/repositories"
)

type ChatService struct {
	convRepo *repositories.ConversationRepository
	msgRepo  *repositories.MessageRepository
}

func NewChatService(convRepo *repositories.ConversationRepository, msgRepo *repositories.MessageRepository) *ChatService {
	return &ChatService{convRepo: convRepo, msgRepo: msgRepo}
}

func (s *ChatService) StartConversation(userID int64, materialID int64) (*models.Conversation, error) {
	conv, err := s.convRepo.GetOrCreate(materialID, userID)
	if err != nil {
		return nil, fmt.Errorf("start conversation: %w", err)
	}
	if conv.OwnerID == userID {
		return nil, errors.New("cannot start conversation with yourself")
	}
	return conv, nil
}

func (s *ChatService) ListConversations(userID int64) ([]models.Conversation, error) {
	return s.convRepo.ListByUserID(userID)
}

func (s *ChatService) GetMessages(userID, convID int64) ([]models.Message, error) {
	ok, err := s.convRepo.IsParticipant(convID, userID)
	if err != nil {
		return nil, fmt.Errorf("check participant: %w", err)
	}
	if !ok {
		return nil, errors.New("unauthorized: not a participant")
	}

	if err := s.msgRepo.MarkAsRead(convID, userID); err != nil {
		return nil, fmt.Errorf("mark as read: %w", err)
	}

	return s.msgRepo.ListByConversation(convID)
}

func (s *ChatService) SaveMessage(convID, senderID int64, content string) (*models.Message, error) {
	ok, err := s.convRepo.IsParticipant(convID, senderID)
	if err != nil {
		return nil, fmt.Errorf("check participant: %w", err)
	}
	if !ok {
		return nil, errors.New("unauthorized: not a participant")
	}

	msg := &models.Message{
		ConversationID: convID,
		SenderID:       senderID,
		Content:        content,
	}
	if err := s.msgRepo.Create(msg); err != nil {
		return nil, fmt.Errorf("save message: %w", err)
	}
	return msg, nil
}
