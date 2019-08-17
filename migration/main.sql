create table item_dependencies
(
  id           integer not null
    constraint site_servers_pk
      primary key autoincrement,
  item_id      integer,
  item_dest_id integer,
  reason       text
);

INSERT INTO item_dependencies (id, item_id, item_dest_id, reason) VALUES (1, 1, 2, 'ホスティング');
INSERT INTO item_dependencies (id, item_id, item_dest_id, reason) VALUES (2, 1, 3, 'ブログ検索');
INSERT INTO item_dependencies (id, item_id, item_dest_id, reason) VALUES (3, 4, 5, '顧客情報連携');
INSERT INTO item_dependencies (id, item_id, item_dest_id, reason) VALUES (4, 4, 6, 'インフラ');
INSERT INTO item_dependencies (id, item_id, item_dest_id, reason) VALUES (5, 7, 2, 'ホスティング');
INSERT INTO item_dependencies (id, item_id, item_dest_id, reason) VALUES (6, 7, 8, 'HTML生成');

create table item_types
(
  id   integer not null
    constraint item_types_pk
      primary key autoincrement,
  name text
);

INSERT INTO item_types (id, name) VALUES (1, 'site');
INSERT INTO item_types (id, name) VALUES (2, 'service');
INSERT INTO item_types (id, name) VALUES (3, 'application');

create table items
(
  id          integer not null
    constraint servers_pk
      primary key autoincrement,
  name        text,
  description text,
  type_id     integer
);

INSERT INTO items (id, name, description, type_id) VALUES (1, 'portfolio.example.com', 'ポートフォリオサイト', 1);
INSERT INTO items (id, name, description, type_id) VALUES (2, 'Firebase', 'PaaS', 2);
INSERT INTO items (id, name, description, type_id) VALUES (3, 'Algolia', '全文検索エンジン', 2);
INSERT INTO items (id, name, description, type_id) VALUES (4, 'service.example.com', '基幹システム', 1);
INSERT INTO items (id, name, description, type_id) VALUES (5, 'Salesforce', '顧客管理システム', 2);
INSERT INTO items (id, name, description, type_id) VALUES (6, 'AWS', 'インフラ', 2);
INSERT INTO items (id, name, description, type_id) VALUES (7, 'blog.example.com', 'ブログサイト', 1);
INSERT INTO items (id, name, description, type_id) VALUES (8, 'Hugo', 'SSGツール', 3);