<?php
declare(strict_types=1);
session_start();
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config/db_config.php';

const REMEMBER_COOKIE = 'ccs_remember';

function json_out(bool $ok, string $message = '', array $data = [], int $status = 200): never {
    http_response_code($status);
    echo json_encode(['ok'=>$ok,'message'=>$message,'data'=>$data], JSON_UNESCAPED_UNICODE);
    exit;
}
function body(): array {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw ?: '{}', true);
    return is_array($data) ? $data : [];
}
function csrf_token(): string {
    if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));
    return $_SESSION['csrf'];
}
function require_csrf(array $data): void {
    if (!hash_equals((string)($_SESSION['csrf'] ?? ''), (string)($data['csrf'] ?? ''))) {
        json_out(false, 'Invalid security token. Refresh and try again.', [], 419);
    }
}
function user(): ?array { return $_SESSION['user'] ?? null; }
function require_login(): array {
    $u = user();
    if (!$u) json_out(false, 'Please sign in first.', [], 401);
    return $u;
}
function require_roles(array $roles): array {
    $u = require_login();
    if (!in_array($u['role'], $roles, true)) json_out(false, 'You do not have permission for this action.', [], 403);
    return $u;
}
function clean(string $v): string { return trim($v); }
function session_user_from_row(array $row): array {
    return [
        'id'=>(int)$row['id'],'username'=>$row['username'],'email'=>$row['email'],'student_no'=>$row['student_no'],
        'full_name'=>$row['full_name'],'role'=>$row['role'],'course'=>$row['course'],'year_level'=>$row['year_level'],
        'section'=>$row['section'],'contact_no'=>$row['contact_no'],'photo_url'=>$row['photo_url']
    ];
}
function remember_cookie_options(int $expires): array {
    return ['expires'=>$expires,'path'=>'/','secure'=>!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off','httponly'=>true,'samesite'=>'Lax'];
}
function restore_remembered_session(): void {
    if (!empty($_SESSION['user']) || empty($_COOKIE[REMEMBER_COOKIE])) return;
    try {
        $s=db()->prepare('SELECT rt.id,rt.user_id,u.* FROM remember_tokens rt JOIN users u ON u.id=rt.user_id WHERE rt.token_hash=? AND rt.expires_at>NOW() AND u.is_active=1 LIMIT 1');
        $s->execute([hash('sha256',(string)$_COOKIE[REMEMBER_COOKIE])]); $row=$s->fetch();
        if (!$row) return;
        $_SESSION['user']=session_user_from_row($row); csrf_token();
        db()->prepare('UPDATE remember_tokens SET last_used_at=NOW() WHERE id=?')->execute([$row['id']]);
    } catch (Throwable $e) {
        // A missing optional remember-token table must not break JSON responses.
    }
}
function audit(PDO $pdo, ?int $uid, string $action, string $details=''): void {
    $s=$pdo->prepare("INSERT INTO audit_logs(user_id,action,details) VALUES(?,?,?)");
    $s->execute([$uid,$action,$details]);
}
restore_remembered_session();
