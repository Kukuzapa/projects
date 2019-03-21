
-- +goose Up
-- SQL in section 'Up' is executed when this migration is applied
INSERT INTO nodes (node) VALUES ('get-net');
INSERT INTO grants (grnt) VALUES ('pass');
INSERT INTO grants (grnt) VALUES ('insert');
INSERT INTO grants (grnt) VALUES ('delete');
INSERT INTO grants (grnt) VALUES ('replace');
INSERT INTO grants (grnt) VALUES ('read');
INSERT INTO grants (grnt) VALUES ('update');
INSERT INTO grants (grnt) VALUES ('access');
INSERT INTO roles (role) VALUES ('admins');
-- +goose Down
-- SQL section 'Down' is executed when this migration is rolled back

