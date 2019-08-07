package main

import (
	"encoding/json"
	_ "github.com/mattn/go-sqlite3"
	"net/http"
)

func main() {
	http.HandleFunc("/item_types", itemTypesHandler)
	http.HandleFunc("/items", itemsHandler)
	http.HandleFunc("/dependency_items", dependencyItemsHandler)
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

func dependencyItemsHandler(w http.ResponseWriter, r *http.Request) {
	types := DependencyItems{}
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
