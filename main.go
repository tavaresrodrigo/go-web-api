package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type book struct {
	ID string `json:"id"`
	Title string `json:"title"`
	Author string `json:"author"`
	Read bool `json:"read"`
}

var books =[]book{
	{ID: "1", Title: "Book 1", Author: "Author 1", Read: false},
	{ID: "2", Title: "Book 2", Author: "Author 2", Read: false},
	{ID: "3", Title: "Book 3", Author: "Author 3", Read: true},
}

func main() {

	router := gin.Default()
	router.GET("/books", getBooks)
	router.GET("/books/:id", getBookByID)
	router.POST("/books", addBook)

	router.Run(":8080")

}

func getBooks(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, books)
}

func getBookByID(c *gin.Context) {
	id := c.Param("id")
	for _, book := range books {
		if book.ID == id {
			c.IndentedJSON(http.StatusOK, book)
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Book not found"})
}

func addBook(c *gin.Context) {
	var book book
	c.BindJSON(&book)
	books = append(books, book)
	c.JSON(http.StatusOK, books)
}