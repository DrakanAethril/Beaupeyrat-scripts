<?php
/*
This script processes rows from ldap_manage_password one by one and calls change_password.sh for each.
The script stops and exits when no pending row is left.
*/

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/tools/functions.php';

$pdo = getConnection();

while ($line = getPasswordLine($pdo)) {
    // A specific password can be requested up front (encrypted into the same `password` column
    // at insert time) - getPasswordLine() decrypts it back for us. Keep it if present, otherwise
    // fall back to generating a random one, same as account creation does for new accounts.
    $password = $line['password'] ?? generateUserPassword();

    $args = [$line['login'], $password];
    $cmd = PWD_CHANGE_SCRIPT . ' ' . implode(' ', array_map('escapeshellarg', $args));
    exec($cmd, $output, $exitCode);

    if ($exitCode === 0) {
        $update = $pdo->prepare('UPDATE ldap_manage_password SET state = 2, ended_at = NOW(), password = AES_ENCRYPT(:password, :aes_key) WHERE id = :id');
        $update->execute([':password' => $password, ':aes_key' => AES_KEY, ':id' => $line['id']]);
    } else {
        $update = $pdo->prepare('UPDATE ldap_manage_password SET state = 3, ended_at = NOW(), password = AES_ENCRYPT(:password, :aes_key), log = :log WHERE id = :id');
        $update->execute([':password' => $password, ':aes_key' => AES_KEY, ':log' => implode("\n", $output), ':id' => $line['id']]);
    }
}
