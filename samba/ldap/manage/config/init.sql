CREATE TABLE IF NOT EXISTS `ldap_manage_user` (
    `id`          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `firstname`   VARCHAR(255)     NOT NULL,
    `lastname`    VARCHAR(255)     NOT NULL,
    `user_type`   VARCHAR(255)     NOT NULL,
    `user_groups` VARCHAR(255)     NOT NULL DEFAULT '',
    `action_type` VARCHAR(255)     NOT NULL,
    `added_at`    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `added_by`    VARCHAR(255)     NOT NULL DEFAULT 'direct',
    `login`       VARCHAR(255)     DEFAULT NULL,
    `password`    VARBINARY(255)   DEFAULT NULL,
    `state`       TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `pid`         INT UNSIGNED     DEFAULT NULL,
    `started_at`  DATETIME         DEFAULT NULL,
    `ended_at`    DATETIME         DEFAULT NULL,
    `log`         TEXT             DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11000 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ldap_manage_group` (
    `id`         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `name`       VARCHAR(255)     NOT NULL,
    `added_at`   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `added_by`   VARCHAR(255)     NOT NULL DEFAULT 'direct',
    `state`      TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `pid`        INT UNSIGNED     DEFAULT NULL,
    `started_at` DATETIME         DEFAULT NULL,
    `ended_at`   DATETIME         DEFAULT NULL,
    `log`        TEXT             DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=99100 DEFAULT CHARSET=utf8mb4;

ALTER TABLE `ldap_manage_group` ADD UNIQUE(`name`); 
ALTER TABLE `ldap_manage_group` ADD `description` VARCHAR(255) NOT NULL AFTER `name`;