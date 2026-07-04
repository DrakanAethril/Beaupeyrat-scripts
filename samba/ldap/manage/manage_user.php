<?php
/*
This script get line per line lines in the ldap_manage table and exec the create_account.sh for each line.
The script stops and exits when there is no line available left.
*/

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/tools/functions.php';

$pdo = getConnection();

while ($line = getUserLine($pdo)) {
    $script = match($line['action_type']) {
        'account_create' => CREATE_ACCOUNT_SCRIPT,
        'pwd_change'     => PWD_CHANGE_SCRIPT,
    };
    $line['login']    = generateUniqueLogin($pdo, $line['firstname'], $line['lastname']);
    $line['password'] = generateUserPassword();

    $secondaryGroups = implode('|', array_filter(
        explode('|', $line['user_groups']),
        fn($g) => $g !== 'admin'
    ));

    $args = [$line['firstname'], $line['lastname'], $line['user_type'], $secondaryGroups, $line['login'], $line['id'], $line['password']];
    $cmd = $script . ' ' . implode(' ', array_map('escapeshellarg', $args));
    exec($cmd, $output, $exitCode);

    if ($exitCode === 0) {
        $update = $pdo->prepare('UPDATE ldap_manage_user SET state = 2, ended_at = NOW(), login = :login, password = AES_ENCRYPT(:password, :aes_key) WHERE id = :id');
        $update->execute([':login' => $line['login'], ':password' => $line['password'], ':aes_key' => AES_KEY, ':id' => $line['id']]);
    } else {
        $update = $pdo->prepare('UPDATE ldap_manage_user SET state = 3, ended_at = NOW(), login = :login, password = AES_ENCRYPT(:password, :aes_key), log = :log WHERE id = :id');
        $update->execute([':login' => $line['login'], ':password' => $line['password'], ':aes_key' => AES_KEY, ':log' => implode("\n", $output), ':id' => $line['id']]);
    }
}
