<?php
/*
This script get line per line lines in the ldap_manage table and exec the create_account.sh for each line.
The script stops and exits when there is no line available left.
*/

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/tools/functions.php';

$pdo = getConnection();

while ($line = getLine($pdo)) {
    $script = match($line['change_type']) {
        'account_create' => CREATE_ACCOUNT_SCRIPT,
        'pwd_change'     => PWD_CHANGE_SCRIPT,
    };

    $cmd = $script . ' ' . implode(' ', array_map('escapeshellarg', array_values($line)));
    exec($cmd, $output, $exitCode);

    if ($exitCode === 0) {
        $update = $pdo->prepare('UPDATE ldap_manage SET state = 2, ended_at = NOW() WHERE id = :id');
        $update->execute([':id' => $line['id']]);
    } else {
        $update = $pdo->prepare('UPDATE ldap_manage SET state = 3, ended_at = NOW(), log = :log WHERE id = :id');
        $update->execute([':log' => implode("\n", $output), ':id' => $line['id']]);
    }
}
