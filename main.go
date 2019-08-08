package main

import (
	"encoding/json"
	"fmt"
	_ "github.com/mattn/go-sqlite3"
	"net/http"
	"strconv"
)

func main() {
	http.HandleFunc("/item_types", itemTypesHandler)
	http.HandleFunc("/items", itemsHandler)
	http.HandleFunc("/item_dependencies", itemDependenciesHandler)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}

func itemTypesHandler(w http.ResponseWriter, r *http.Request) {
	types := ItemTypes{}
	if err := types.Fetch(); err != nil {
		http.Error(w, "Failed fetch", http.StatusInternalServerError)
		return
	}
	j, errJson := json.Marshal(types.Data)
	if errJson != nil {
		http.Error(w, "Failed marshall json", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	if _, err := w.Write(j); err != nil {
		http.Error(w, "Failed response json", http.StatusInternalServerError)
		return
	}
}

func itemsHandler(w http.ResponseWriter, r *http.Request) {
	items := Items{}
	if err := items.Fetch(); err != nil {
		http.Error(w, "Failed fetch items", http.StatusInternalServerError)
		return
	}
	j, errJson := json.Marshal(items.Data)
	if errJson != nil {
		http.Error(w, "Failed marshall json", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	if _, err := w.Write(j); err != nil {
		http.Error(w, "Failed response json", http.StatusInternalServerError)
		return
	}
}

func itemDependenciesHandler(w http.ResponseWriter, r *http.Request) {
	queries := r.URL.Query()
	itemId := queries.Get("itemId")
	if itemId == "" {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	id, _ := strconv.Atoi(itemId)

	itemDeps := ItemDependencies{}
	if err := itemDeps.Fetch(id); err != nil {
		fmt.Printf("%v", err)
		http.Error(w, "Failed fetch dependencies", http.StatusInternalServerError)
		return
	}

	item := Item{}
	if err := item.Fetch(id); err != nil {
		fmt.Printf("%v", err)
		http.Error(w, "Failed fetch items", http.StatusInternalServerError)
		return
	}
	itemDeps.Id = item.Id
	itemDeps.Name = item.Name
	itemDeps.Description = item.Description

	j, errJson := json.Marshal(itemDeps)
	if errJson != nil {
		fmt.Printf("%v", errJson)
		http.Error(w, "Failed marshall json", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	if _, err := w.Write(j); err != nil {
		fmt.Printf("%v", err)
		http.Error(w, "Failed response json", http.StatusInternalServerError)
		return
	}
}
