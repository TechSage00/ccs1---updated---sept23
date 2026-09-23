# CCS Student Clearance System — Wireframe UI Build

This package is the existing PHP/MySQL CCS Clearance System updated to use the supplied wireframe visual structure while preserving the existing API architecture.

## Implemented UI

- URS-style authentication screen
- Student registration screen with the supplied registration layout
- Office dashboard layout with URS header, sidebar, stat cards and section table
- Section Clearance layout with Clear All / Exclude Selected
- Per-student mandatory remarks for uncleared/excluded students
- Requirement Settings layout
- Account Settings layout for student and office accounts
- Printable Clearance layout
- Responsive desktop/tablet/mobile styling
- Password show/hide controls
- Logout confirmation
- Existing role-based navigation
- Profile photo upload and Save Changes confirmation
- Existing password reset, Remember Me and authentication APIs retained

## Supplied wireframe student data

The database files now include the 100 QA sample students:

`2026-0001` through `2026-0100`

They are assigned to `BSIT 3-2A` so the Section Clearance screen can load them from MySQL instead of hardcoding the table.

## XAMPP installation

1. Extract this folder into:

`C:\xampp\htdocs\CCS_Clearance_System`

2. Start Apache and MySQL in XAMPP.

3. For a new database, open phpMyAdmin and import:

`database.sql`

4. If you already have the database from an earlier version, run:

`database_migration_qa_fixes.sql`

5. Check:

`config/db_config.php`

Default local XAMPP settings are normally:

- host: `127.0.0.1`
- user: `root`
- password: blank
- database: `ccs_clearance`

6. Open in Chrome:

`http://localhost/CCS_Clearance_System/`

## Demo accounts

All seeded accounts use:

`Password123!`

Student:

`chester@example.com`

Office accounts:

- Laboratory/Shop: `von@example.com`
- Library: `jaypee@example.com`
- Cashier: `denise@example.com`
- Student Development Services: `evelyn@example.com`
- Class Adviser: `yves@example.com`
- Program Head: `richelle@example.com`
- Dean: `joy@example.com`
- Registrar: `lorelie.anthony` is the username; email is `lorelie@example.com`

## Important

The PNG wireframes remain in `/wireframes` as visual references. The application itself uses real HTML/CSS/JavaScript controls rather than putting screenshots over the page.

The visual file names supplied with the project are not assumed to be authoritative because several screenshots are visibly labeled differently from their filenames. The implemented UI therefore follows the actual visual layouts in the supplied screenshots: authentication, dashboard, section clearance, requirements, settings and printable-clearance patterns.

## Profile photos

Profile photos are uploaded through the browser file picker and validated server-side. Files are stored under:

`assets/uploads/profile/`

## Password reset

The existing PHP password-reset token flow remains in place. For local testing, the reset endpoint can expose a generated local reset link when PHP mail delivery is unavailable.

## Development

Stack:

- HTML5
- CSS3
- Vanilla JavaScript
- PHP 8+
- MySQL/MariaDB
- PDO prepared statements

No frontend framework is required.
