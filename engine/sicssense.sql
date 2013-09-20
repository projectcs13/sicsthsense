DROP DATABASE IF EXISTS sicsth2;

CREATE DATABASE IF NOT EXISTS sicsth2;

USE sicsth2;

GRANT ALL PRIVILEGES ON * . *
TO 'sicsthsense'@'localhost' IDENTIFIED BY 'sicsdev'
WITH GRANT OPTION;

CREATE TABLE `actuators` (
	`id`		BIGINT AUTO_INCREMENT NOT NULL,
	`owner_id`	BIGINT,
  	`input_parser`	VARCHAR(255),
	CONSTRAINT pk_actuators PRIMARY KEY (`id`)
);

CREATE TABLE `data_point_double` (
	`id`		BIGINT AUTO_INCREMENT NOT NULL,
  	`stream_id`	BIGINT,
  	`timestamp`	BIGINT,
  	`data`		DOUBLE,
  	CONSTRAINT uq_data_point_DOUBLE_1 UNIQUE (`stream_id`,`timestamp`),
  	CONSTRAINT pk_data_point_DOUBLE PRIMARY KEY (`id`)
);

CREATE TABLE `data_point_string` (
  	`id`		BIGINT AUTO_INCREMENT NOT NULL,
  	`stream_id`	BIGINT,
  	`timestamp`	BIGINT,
  	`data`		VARCHAR(160),
 	CONSTRAINT uq_data_point_string_1 UNIQUE (`stream_id`,`timestamp`),
	CONSTRAINT pk_data_point_string PRIMARY KEY (`id`)
);

CREATE TABLE `functions` (
	`id`		BIGINT AUTO_INCREMENT NOT NULL,
	`owner_id`	BIGINT,
	CONSTRAINT pk_functions PRIMARY KEY (`id`)
);

CREATE TABLE `operators` (
	`id`		BIGINT AUTO_INCREMENT NOT NULL,
	CONSTRAINT pk_operators PRIMARY KEY (`id`)
);

CREATE TABLE `resources` (
	`id`				BIGINT AUTO_INCREMENT NOT NULL,
	`owner_id`			BIGINT,
	`label`				VARCHAR(255),
	`polling_period`		BIGINT,
	`last_posted`			BIGINT,
	`last_polled`			BIGINT,
	`polling_url`			VARCHAR(255),
	`polling_authentication_key`	VARCHAR(255),
	`description`			VARCHAR(255),
	`parent_id`			BIGINT,
	`secret_key`			VARCHAR(255),
	`version`			INTEGER NOT NULL,
	CONSTRAINT uq_resources_1 UNIQUE (`owner_id`,`parent_id`,`label`),
	CONSTRAINT pk_resources PRIMARY KEY (`id`)
);

CREATE TABLE `resource_log` (
	`id`			BIGINT AUTO_INCREMENT NOT NULL,
	`resource_id`		BIGINT,
	`creation_timestamp`	BIGINT,
	`response_timestamp`	BIGINT,
	`parsed_successfully`	TINYINT(1) DEFAULT 0,
	`is_poll`		TINYINT(1) DEFAULT 0,
	`body`			VARCHAR(8192),
	`method`		VARCHAR(255),
	`host_name`		VARCHAR(255),
	`uri`			VARCHAR(255),
	`headers`		VARCHAR(4096),
	`message`		VARCHAR(4096),
	`version`		INTEGER NOT NULL,
	CONSTRAINT uq_resource_log_1 UNIQUE (`resource_id`,`is_poll`),
	CONSTRAINT pk_resource_log PRIMARY KEY (`id`)
);

CREATE TABLE `settings` (
	`id`		BIGINT AUTO_INCREMENT NOT NULL,
	`name`		VARCHAR(255) NOT NULL,
	`val`		VARCHAR(255),
	CONSTRAINT uq_settings_1 UNIQUE (`name`),
	CONSTRAINT pk_settings PRIMARY KEY (`id`)
);

CREATE TABLE `streams` (
	`id`			BIGINT AUTO_INCREMENT NOT NULL,
	`type`			VARCHAR(1),
	`latitude`		DOUBLE,
	`longtitude`		DOUBLE,
	`description`		VARCHAR(255),
	`public_access`		TINYINT(1) DEFAULT 0,
	`public_search`		TINYINT(1) DEFAULT 0,
	`frozen`		TINYINT(1) DEFAULT 0,
	`history_size`		BIGINT,
	`last_updated`		BIGINT,
	`secret_key`		VARCHAR(255),
	`owner_id`		BIGINT,
	`resource_id`		BIGINT,
	`version`		INTEGER NOT NULL,
	CONSTRAINT ck_streams_type CHECK (`type` IN ('U','D','S')),
	CONSTRAINT pk_streams PRIMARY KEY (`id`)
);

CREATE TABLE `parsers` (
	`id`			BIGINT AUTO_INCREMENT NOT NULL,
	`resource_id`		BIGINT,
	`stream_id`		BIGINT,
	`input_parser`		VARCHAR(255),
	`input_type`		VARCHAR(255),
	`timeformat`		VARCHAR(255),
	`data_group`		INTEGER,
	`time_group`		INTEGER,
	`number_of_points`	INTEGER,
	CONSTRAINT pk_parsers PRIMARY KEY (`id`)
);

CREATE TABLE `users` (
	`id`                        BIGINT AUTO_INCREMENT NOT NULL,
	`email`                     VARCHAR(255) NOT NULL,
	`user_name`                 VARCHAR(255) NOT NULL,
	`password`                  VARCHAR(255),
	`first_name`                VARCHAR(255),
	`last_name`                 VARCHAR(255),
	`description`               VARCHAR(2048),
	`latitude`                  DOUBLE,
	`longitude`                 DOUBLE,
	`creation_date`             DATETIME NOT NULL,
	`last_login`                DATETIME,
	`token`                     VARCHAR(255),
	`admin`                     TINYINT(1) DEFAULT 0,
	`version`                   INTEGER NOT NULL,
	CONSTRAINT uq_users_email UNIQUE (`email`),
	CONSTRAINT uq_users_user_name UNIQUE (`user_name`),
	CONSTRAINT pk_users PRIMARY KEY (`id`)
);

CREATE TABLE `vfiles` (
	`id`                        BIGINT AUTO_INCREMENT NOT NULL,
	`path`                      VARCHAR(255) NOT NULL,
	`owner_id`                  BIGINT,
	`type`                      VARCHAR(1) NOT NULL,
	`linked_stream_id`          BIGINT,
	CONSTRAINT ck_vfiles_type CHECK (`type` IN ('F','D')),
	CONSTRAINT uq_vfiles_1 UNIQUE (`owner_id`,`path`),
	CONSTRAINT pk_vfiles PRIMARY KEY (`id`)
);


CREATE TABLE `functions_streams` (
	`functions_id`                   BIGINT NOT NULL,
	`streams_id`                     BIGINT NOT NULL,
	CONSTRAINT pk_functions_streams PRIMARY KEY (`functions_id`, `streams_id`)
);

CREATE TABLE `users_streams` (
	`users_id`                       BIGINT NOT NULL,
	`streams_id`                     BIGINT NOT NULL,
	CONSTRAINT pk_users_streams PRIMARY KEY (`users_id`, `streams_id`)
);

ALTER TABLE `actuators` ADD CONSTRAINT fk_actuators_owner_1 FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_actuators_owner_1 ON `actuators` (`owner_id`);

ALTER TABLE `data_point_double` ADD CONSTRAINT fk_data_point_double_stream_2 FOREIGN KEY (`stream_id`) REFERENCES `streams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_data_point_double_stream_2 ON `data_point_double` (`stream_id`);

ALTER TABLE `data_point_string` ADD CONSTRAINT fk_data_point_string_stream_3 FOREIGN KEY (`stream_id`) REFERENCES `streams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_data_point_string_stream_3 ON `data_point_string` (`stream_id`);

ALTER TABLE `functions` ADD CONSTRAINT fk_functions_owner_4 FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_functions_owner_4 ON `functions` (`owner_id`);

ALTER TABLE `resources` ADD CONSTRAINT fk_resources_owner_5 FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_resources_owner_5 ON `resources` (`owner_id`);

ALTER TABLE `resources` ADD CONSTRAINT fk_resources_parent_6 FOREIGN KEY (`parent_id`) REFERENCES `resources` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_resources_parent_6 ON `resources` (`parent_id`);

ALTER TABLE `resource_log` ADD CONSTRAINT fk_resource_log_resource_7 FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_resource_log_resource_7 ON `resource_log` (`resource_id`);

ALTER TABLE `streams` ADD CONSTRAINT fk_streams_owner_8 FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_streams_owner_8 ON `streams` (`owner_id`);

ALTER TABLE `streams` ADD CONSTRAINT fk_streams_resource_9 FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_streams_resource_9 ON `streams` (`resource_id`);

ALTER TABLE `parsers` ADD CONSTRAINT fk_parsers_resource_10 FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_parsers_resource_10 ON `parsers` (`resource_id`);

ALTER TABLE `parsers` ADD CONSTRAINT fk_parsers_stream_11 FOREIGN KEY (`stream_id`) REFERENCES `streams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_parsers_stream_11 ON `parsers` (`stream_id`);

ALTER TABLE `vfiles` ADD CONSTRAINT fk_vfiles_owner_12 FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_vfiles_owner_12 ON `vfiles` (`owner_id`);

ALTER TABLE `vfiles` ADD CONSTRAINT fk_vfiles_linkedStream_13 FOREIGN KEY (`linked_stream_id`) REFERENCES `streams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE INDEX ix_vfiles_linkedStream_13 ON `vfiles` (`linked_stream_id`);


ALTER TABLE `functions_streams` ADD CONSTRAINT fk_functions_streams_functions_01 FOREIGN KEY (`functions_id`) REFERENCES `functions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `functions_streams` ADD CONSTRAINT fk_functions_streams_streams_02 FOREIGN KEY (`streams_id`) REFERENCES `streams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `users_streams` ADD CONSTRAINT fk_users_streams_users_01 FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `users_streams` ADD CONSTRAINT fk_users_streams_streams_02 FOREIGN KEY (`streams_id`) REFERENCES `streams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;


INSERT INTO `users`(`email`, `user_name`, `password`, `first_name`, `last_name`,
 		    `description`, `latitude`, `longitude`, `creation_date`,
		    `last_login`, `token`, `admin`, `version`)
       VALUES('asd@asd.com', 'Aladdin', 'open sesame', 'Al', 'Addin',
	      'Carpet Maker', 0.0, 0.0, CURDATE(), CURDATE(), 'token', 0, 1);

INSERT INTO `resources`(`owner_id`, `label`, `polling_period`, `last_posted`,
			`last_polled`, `polling_url`, `polling_authentication_key`,
			`description`, `parent_id`, `secret_key`, `version`)
       VALUES(1, 'New Resource', NULL, NULL, NULL, NULL, NULL, 'Test Resource',
	      1, 'secret', 1);
