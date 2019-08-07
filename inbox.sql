create table item_types
(
  id   integer not null constraint item_types_pk primary key autoincrement,
  name text
);

create table items
(
  id                 integer not null constraint servers_pk primary key autoincrement,
  name               text,
  private_ip_address text,
  public_ip_address  text,
  description        text,
  type_id            integer
);

create table item_dependencies
(
  id           integer not null constraint site_servers_pk primary key autoincrement,
  item_id      integer,
  item_dest_id integer,
  reason       text
);

-- 依存関係を取得する
select items.id,
       item_types.name,
       items.name,
       item_dependencies.item_dest_id,
       dependency_item_types.name,
       dependency_items.name,
       dependency_items.description
from items
       left join item_types on item_types.id = items.type_id
       left join item_dependencies on item_dependencies.item_id = items.id
       left join items dependency_items on dependency_items.id = item_dependencies.item_dest_id
       left join item_types dependency_item_types on dependency_item_types.id = dependency_items.type_id;

-- 被依存関係を取得する
select items.id,
       item_types.name,
       items.name,
       item_dependencies.item_dest_id,
       dependency_item_types.name,
       dependency_items.name,
       dependency_items.description
from items
       left join item_types on item_types.id = items.type_id
       left join item_dependencies on item_dependencies.item_dest_id = items.id
       left join items dependency_items on dependency_items.id = item_dependencies.item_id
       left join item_types dependency_item_types on dependency_item_types.id = dependency_items.type_id;
