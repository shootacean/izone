package main

import (
	"database/sql"
	"fmt"
)

const driverName = "sqlite3"
const dbName = "./izone.sqlite"

type ItemType struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
}

type ItemTypes struct {
	Data []ItemType
}

func (types *ItemTypes) Fetch() error {
	db, err := sql.Open(driverName, dbName)
	if err != nil {
		return err
	}
	rows, errQuery := db.Query("select id, name from item_types")
	if errQuery != nil {
		return errQuery
	}
	defer rows.Close()
	
	for rows.Next() {
		i := ItemType{}
		if err := rows.Scan(&i.Id, &i.Name); err != nil {
			return err
		}
		types.Data = append(types.Data, i)
	}
	return nil
}

type Item struct {
	Id          int    `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

func (item *Item) Fetch(id int) error {
	db, err := sql.Open(driverName, dbName)
	if err != nil {
		fmt.Printf("%v", err)
		return err
	}
	rows, errQuery := db.Query("SELECT id, name, description FROM items WHERE id = $1", id)
	if errQuery != nil {
		fmt.Printf("%v", errQuery)
		return errQuery
	}
	defer rows.Close()
	
	for rows.Next() {
		if err := rows.Scan(&item.Id, &item.Name, &item.Description); err != nil {
			fmt.Printf("%v", err)
			return err
		}
	}
	return nil
}

type Items struct {
	Data []Item
}

func (items *Items) Fetch() error {
	db, err := sql.Open(driverName, dbName)
	if err != nil {
		return err
	}
	rows, errQuery := db.Query("select id, name, description from items")
	if errQuery != nil {
		return errQuery
	}
	defer rows.Close()
	
	for rows.Next() {
		i := Item{}
		if err := rows.Scan(&i.Id, &i.Name, &i.Description); err != nil {
			return err
		}
		items.Data = append(items.Data, i)
	}
	return nil
}

type ItemDependency struct {
	Item
	Reason string `json:"reason"`
}

type ItemDependencies struct {
	Item
	Dependencies []ItemDependency `json:"dependencies"`
}

func (itemDeps *ItemDependencies) Fetch(itemId int) error {
	db, err := sql.Open(driverName, dbName)
	if err != nil {
		fmt.Printf("%v", err)
		return err
	}
	rows, errQuery := db.Query(`
		SELECT
       		item_dependencies.item_dest_id AS id,
       		dependency_items.name AS name,
       		dependency_items.description AS description,
       		item_dependencies.reason AS reason
		FROM items
       		LEFT JOIN item_types ON item_types.id = items.type_id
       		INNER JOIN item_dependencies ON item_dependencies.item_id = items.id
       		LEFT JOIN items dependency_items ON dependency_items.id = item_dependencies.item_dest_id
       		LEFT JOIN item_types dependency_item_types ON dependency_item_types.id = dependency_items.type_id
		WHERE items.id = $1
	`, itemId)
	if errQuery != nil {
		fmt.Printf("%v", errQuery)
		return errQuery
	}
	defer rows.Close()
	
	for rows.Next() {
		i := ItemDependency{}
		if err := rows.Scan(&i.Id, &i.Name, &i.Description, &i.Reason); err != nil {
			fmt.Printf("%v", err)
			return err
		}
		itemDeps.Dependencies = append(itemDeps.Dependencies, i)
	}
	return nil
}

func (itemDeps *ItemDependencies) FetchDepended(itemId int) error {
	db, err := sql.Open(driverName, dbName)
	if err != nil {
		fmt.Printf("%v", err)
		return err
	}
	rows, errQuery := db.Query(`
		SELECT
    		item_dependencies.item_id AS id,
    		dependency_items.name AS name,
    		dependency_items.description AS description,
    		item_dependencies.reason AS reason
		FROM items
       		LEFT JOIN item_types ON item_types.id = items.type_id
       		INNER JOIN item_dependencies ON item_dependencies.item_dest_id = items.id
       		LEFT JOIN items dependency_items ON dependency_items.id = item_dependencies.item_id
       		LEFT JOIN item_types dependency_item_types ON dependency_item_types.id = dependency_items.type_id
	WHERE items.id = $1
	`, itemId)
	if errQuery != nil {
		fmt.Printf("%v", errQuery)
		return errQuery
	}
	defer rows.Close()
	
	for rows.Next() {
		i := ItemDependency{}
		if err := rows.Scan(&i.Id, &i.Name, &i.Description, &i.Reason); err != nil {
			fmt.Printf("%v", err)
			return err
		}
		itemDeps.Dependencies = append(itemDeps.Dependencies, i)
	}
	return nil
}
