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
function getUserLine(PDO $pdo) {
    $pid = getPid();

    $pdo->beginTransaction();

    $update = $pdo->prepare('UPDATE ldap_manage_user SET state = 1, pid = :pid, started_at = NOW() WHERE state = 0 AND pid IS NULL LIMIT 1');
    $update->execute([':pid' => $pid]);

    $select = $pdo->prepare('SELECT id, firstname, lastname, user_type, user_groups, action_type FROM ldap_manage_user WHERE state = 1 AND pid = :pid LIMIT 1');
    $select->execute([':pid' => $pid]);
    $line = $select->fetch(PDO::FETCH_ASSOC);

    $pdo->commit();

    return $line;
}

// Generate a unique login: first letter of firstname + lastname (lowercased, ASCII-safe).
// If the candidate already exists in ldap_manage_user, append 01, 02, … until unique.
function generateUniqueLogin(PDO $pdo, string $firstname, string $lastname): string {
    $clean = fn(string $s) => preg_replace('/[^a-z]/', '', strtolower(iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $s)));
    $base = mb_substr($clean($firstname), 0, 1) . $clean($lastname);

    $check = $pdo->prepare('SELECT COUNT(*) FROM ldap_manage_user WHERE login = :login');

    $check->execute([':login' => $base]);
    if ((int) $check->fetchColumn() === 0) {
        return $base;
    }

    for ($i = 1; $i <= 99; $i++) {
        $candidate = $base . sprintf('%02d', $i);
        $check->execute([':login' => $candidate]);
        if ((int) $check->fetchColumn() === 0) {
            return $candidate;
        }
    }

    return $base . '.' .uniqid();
}

// Generate a random password.
// Rules:
//   - 14 characters total
//   - at least 1 uppercase letter  (A-Z)
//   - at least 1 lowercase letter  (a-z)
//   - at least 1 digit             (0-9)
//   - at least 1 special character (!#@?+=)
//   - remaining 10 characters drawn from the combined pool
//   - uses random_int() throughout for cryptographic randomness
// Examples: "kR7!bTm#2nQpLz", "A3@xWqp+oN5rZs", "Bv!9mKzQ2=rLtX"
function generateUserPassword(): string {
    $upper   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $lower   = 'abcdefghijklmnopqrstuvwxyz';
    $digits  = '0123456789';
    $special = '!#@?+=';
    $all     = $upper . $lower . $digits . $special;

    $chars = [
        $upper[random_int(0, strlen($upper) - 1)],
        $lower[random_int(0, strlen($lower) - 1)],
        $digits[random_int(0, strlen($digits) - 1)],
        $special[random_int(0, strlen($special) - 1)],
    ];

    for ($i = 0; $i < 10; $i++) {
        $chars[] = $all[random_int(0, strlen($all) - 1)];
    }

    // Fisher-Yates shuffle using random_int to avoid mt_rand bias
    for ($i = count($chars) - 1; $i > 0; $i--) {
        $j = random_int(0, $i);
        [$chars[$i], $chars[$j]] = [$chars[$j], $chars[$i]];
    }

    return implode('', $chars);
}
