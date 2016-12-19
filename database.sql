CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE motorcycles (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

INSERT INTO
  houses (id, address)
VALUES
  (1, '100 Market Street'),
  (2, '136 Taylor Street');

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, 'John', 'Doe', 1),
  (2, 'Kelly', 'Andrews', 1),
  (3, 'Oliver', 'Green', 2),
  (4, 'Andrew', 'Baker', 2),
  (5, 'Amber', 'Autumn', NULL);

INSERT INTO
  motorcycles (id, name, owner_id)
VALUES
  (1, 'Yamaha R1', 1),
  (2, 'Suzuki Hayabusa', 2),
  (3, 'Honda CBR600rr', 3),
  (4, 'Harley Iron 883', 4),
  (5, 'Honda Goldwing', 5);
