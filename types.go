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
	TypeId      int    `json:"typeId"`
}

type Items struct {
	Data []Item
}

func (items *Items) Fetch() error {
	db, err := sql.Open(driverName, dbName)
	if err != nil {
		return err
	}
	rows, errQuery := db.Query("select id, name, type_id from items")
	if errQuery != nil {
		return errQuery
	}
	defer rows.Close()
	
	for rows.Next() {
		i := Item{}
		if err := rows.Scan(&i.Id, &i.Name, &i.TypeId); err != nil {
			return err
		}
		items.Data = append(items.Data, i)
	}
	return nil
}

type DependencyItem struct {
	Id                   int            `json:"id"`
	TypeName             string         `json:"typeName"`
	Name                 string         `json:"name"`
	DepToItemId          sql.NullInt64  `json:"depToItemId"`
	DepToItemTypeName    sql.NullString `json:"depToItemTypeName"`
	DepToItemName        sql.NullString `json:"depToItemName"`
	DepToItemDescription sql.NullString `json:"depToItemDescription"`
	DepReason            sql.NullString `json:"depReason"`
}

type DependencyItems struct {
	Data []DependencyItem
}

func (depItems *DependencyItems) Fetch() error {
	db, err := sql.Open(driverName, dbName)
	if err != nil {
		fmt.Printf("%v", err)
		return err
	}
	rows, errQuery := db.Query(`
		SELECT
			items.id,
       		item_types.name as type_name,
       		items.name,
       		item_dependencies.item_dest_id AS dep_to_item_id,
       		dependency_item_types.name AS dep_to_item_type_name,
       		dependency_items.name AS dep_to_item_name,
       		dependency_items.description AS dep_to_item_description,
       		item_dependencies.reason AS dep_reason
		FROM items
       		LEFT JOIN item_types ON item_types.id = items.type_id
       		LEFT JOIN item_dependencies ON item_dependencies.item_id = items.id
       		LEFT JOIN items dependency_items ON dependency_items.id = item_dependencies.item_dest_id
       		LEFT JOIN item_types dependency_item_types ON dependency_item_types.id = dependency_items.type_id
	`)
	if errQuery != nil {
		fmt.Printf("%v", errQuery)
		return errQuery
	}
	defer rows.Close()
	
	for rows.Next() {
		i := DependencyItem{}
		if err := rows.Scan(&i.Id, &i.TypeName, &i.Name, &i.DepToItemId, &i.DepToItemTypeName, &i.DepToItemName, &i.DepToItemDescription, &i.DepReason); err != nil {
			fmt.Printf("%v", err)
			return err
		}
		depItems.Data = append(depItems.Data, i)
	}
	return nil
}
