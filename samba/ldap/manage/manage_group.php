<?php
/*
This script processes rows from ldap_manage_group one by one and calls create_group.sh for each.
The script stops and exits when no pending row is left.
*/

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/tools/functions.php';

$pdo = getConnection();

while ($line = getGroupLine($pdo)) {
    $args = [$line['name'], $line['id']];
    $cmd = CREATE_GROUP_SCRIPT . ' ' . implode(' ', array_map('escapeshellarg', $args));
    exec($cmd, $output, $exitCode);

    if ($exitCode === 0) {
        $update = $pdo->prepare('UPDATE ldap_manage_group SET state = 2, ended_at = NOW() WHERE id = :id');
        $update->execute([':id' => $line['id']]);
    } else {
        $update = $pdo->prepare('UPDATE ldap_manage_group SET state = 3, ended_at = NOW(), log = :log WHERE id = :id');
        $update->execute([':log' => implode("\n", $output), ':id' => $line['id']]);
    }
}
