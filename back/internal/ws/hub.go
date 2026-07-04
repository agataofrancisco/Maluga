package ws

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type Client struct {
	ID   int64
	Hub  *Hub
	Conn *websocket.Conn
	Send chan []byte
	mu   sync.Mutex
}

type Hub struct {
	clients    map[int64]*Client
	register   chan *Client
	unregister chan *Client
	broadcast  chan BroadcastMessage
	mu         sync.RWMutex
}

type BroadcastMessage struct {
	UserIDs []int64
	Data    []byte
}

func NewHub() *Hub {
	return &Hub{
		clients:    make(map[int64]*Client),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan BroadcastMessage, 256),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			if old, ok := h.clients[client.ID]; ok {
				close(old.Send)
			}
			h.clients[client.ID] = client
			h.mu.Unlock()
		case client := <-h.unregister:
			h.mu.Lock()
			if c, ok := h.clients[client.ID]; ok && c == client {
				delete(h.clients, client.ID)
				close(client.Send)
			}
			h.mu.Unlock()
		case msg := <-h.broadcast:
			h.mu.RLock()
			for _, uid := range msg.UserIDs {
				if client, ok := h.clients[uid]; ok {
					select {
					case client.Send <- msg.Data:
					default:
						close(client.Send)
						delete(h.clients, uid)
					}
				}
			}
			h.mu.RUnlock()
		}
	}
}

func (h *Hub) SendToUsers(userIDs []int64, data []byte) {
	h.broadcast <- BroadcastMessage{UserIDs: userIDs, Data: data}
}

func (h *Hub) Register(client *Client) {
	h.register <- client
}

func (h *Hub) Unregister(client *Client) {
	h.unregister <- client
}

func (c *Client) ReadPump() {
	defer func() {
		c.Hub.Unregister(c)
		c.Conn.Close()
	}()

	for {
		_, message, err := c.Conn.ReadMessage()
		if err != nil {
			break
		}
		log.Printf("WS received from user %d: %s", c.ID, string(message))
	}
}

func (c *Client) WritePump() {
	defer c.Conn.Close()

	for {
		message, ok := <-c.Send
		if !ok {
			c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
			return
		}

		c.mu.Lock()
		err := c.Conn.WriteMessage(websocket.TextMessage, message)
		c.mu.Unlock()
		if err != nil {
			return
		}
	}
}

func ServeWS(hub *Hub, w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WS upgrade error: %v", err)
		return
	}

	userIDStr := r.URL.Query().Get("user_id")
	var userID int64
	for _, ch := range userIDStr {
		if ch >= '0' && ch <= '9' {
			userID = userID*10 + int64(ch-'0')
		}
	}
	if userID == 0 {
		conn.Close()
		return
	}

	client := &Client{
		ID:   userID,
		Hub:  hub,
		Conn: conn,
		Send: make(chan []byte, 256),
	}

	hub.Register(client)

	go client.WritePump()
	go client.ReadPump()

	welcome, _ := json.Marshal(map[string]interface{}{
		"type":    "connected",
		"user_id": userID,
	})
	client.Send <- welcome
}
