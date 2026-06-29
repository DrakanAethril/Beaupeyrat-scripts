<?php
function getConnection(): PDO {
    return new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8',
        DB_USER,
        DB_PASS,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
}

// Get the current PHP process ID
function getPid() {
    return getmypid();
}

// Update a line in a ldap_manage table with the current php process ID and change state from 0 to 1
// Select a line in state 1 with the current php process ID
function getLine(PDO $pdo) {
    $pid = getPid();

    $pdo->beginTransaction();

    $update = $pdo->prepare('UPDATE ldap_manage SET state = 1, pid = :pid, started_at = NOW() WHERE state = 0 AND pid IS NULL LIMIT 1');
    $update->execute([':pid' => $pid]);

    $select = $pdo->prepare('SELECT * FROM ldap_manage WHERE state = 1 AND pid = :pid LIMIT 1');
    $select->execute([':pid' => $pid]);
    $line = $select->fetch(PDO::FETCH_ASSOC);

    $pdo->commit();

    return $line;
}

