<?php
require_once __DIR__ . '/bootstrap.php';
$pdo=db(); $u=require_login(); $action=$_GET['action']??'list';

function dept_for_role(string $role): ?string {
    return ['lab'=>'Laboratory/Shop','library'=>'Library','cashier'=>'Cashier','sds'=>'Student Development Services','adviser'=>'Class Adviser','program_head'=>'Program Head','dean'=>'Dean','registrar'=>'Registrar'][$role]??null;
}
if($action==='student'){
    if($u['role']!=='student') json_out(false,'Student access only.',[],403);
    $s=$pdo->prepare("SELECT d.id,d.name department,u.full_name officer,c.status,c.cleared_at,c.remarks
        FROM departments d LEFT JOIN office_assignments oa ON oa.department_id=d.id AND oa.course=?
        LEFT JOIN users u ON u.id=oa.user_id LEFT JOIN clearances c ON c.student_id=? AND c.department_id=d.id
        WHERE d.is_active=1 ORDER BY d.sort_order");
    $s->execute([$u['course'],$u['id']]); $departments=$s->fetchAll();
    $s=$pdo->prepare("SELECT d.name department,r.requirement_text,r.visibility FROM requirements r JOIN departments d ON d.id=r.department_id
        WHERE r.visibility=1 AND r.is_active=1 ORDER BY d.sort_order,r.id"); $s->execute(); $req=$s->fetchAll();
    json_out(true,'',['departments'=>$departments,'requirements'=>$req]);
}
$role=$u['role']; $deptName=dept_for_role($role);
if(!$deptName) json_out(false,'This account has no office clearance actions.',[],403);
$s=$pdo->prepare("SELECT id FROM departments WHERE name=?");$s->execute([$deptName]);$deptId=(int)$s->fetchColumn();

if($action==='section'){
    $section=clean((string)($_GET['section']??''));
    $s=$pdo->prepare("SELECT u.id,u.student_no,u.full_name,u.section,u.course,COALESCE(c.status,'pending') status,c.remarks,c.cleared_at
        FROM users u LEFT JOIN clearances c ON c.student_id=u.id AND c.department_id=?
        WHERE u.role='student' AND u.course=? AND u.section=? ORDER BY u.full_name");
    $s->execute([$deptId,$u['course'],$section]); $students=$s->fetchAll();
    json_out(true,'',['section'=>$section,'students'=>$students]);
}
$data=body(); require_csrf($data);
if($action==='clear_all'){
    $section=clean((string)($data['section']??''));
    $s=$pdo->prepare("SELECT u.id FROM users u WHERE u.role='student' AND u.course=? AND u.section=?");
    $s->execute([$u['course'],$section]); $ids=array_column($s->fetchAll(),'id');
    $requested=array_map('intval',$data['student_ids']??[]);
    if($requested)$ids=array_values(array_intersect($ids,$requested));
    $exclude=array_map('intval',$data['exclude']??[]);
    $excludeRemarks=clean((string)($data['exclude_remarks']??''));
    $excludeRemarksMap=is_array($data['exclude_remarks_map']??null)?$data['exclude_remarks_map']:[];
    if($exclude){
        foreach($exclude as $eid){
            $remark=clean((string)($excludeRemarksMap[(string)$eid]??$excludeRemarks));
            if($remark==='') json_out(false,'A remark is required for every excluded student.',[],422);
        }
    }
    $pdo->beginTransaction();
    try {
        $ensure=$pdo->prepare("INSERT INTO clearances(student_id,department_id,status) VALUES(?,?,'pending') ON DUPLICATE KEY UPDATE student_id=VALUES(student_id)");
        $up=$pdo->prepare("UPDATE clearances SET status='cleared',cleared_at=NOW(),remarks=NULL,updated_by=? WHERE department_id=? AND student_id=?");
        foreach($ids as $id){$ensure->execute([$id,$deptId]);if(!in_array((int)$id,$exclude,true))$up->execute([$u['id'],$deptId,$id]);}
        if($exclude){
            $pending=$pdo->prepare("UPDATE clearances SET status='pending',cleared_at=NULL,remarks=?,updated_by=? WHERE department_id=? AND student_id=?");
            foreach($ids as $id) if(in_array((int)$id,$exclude,true)){
                $remark=clean((string)($excludeRemarksMap[(string)$id]??$excludeRemarks));
                $pending->execute([$remark,$u['id'],$deptId,$id]);
            }
        }
        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }
    audit($pdo,$u['id'],'clear_all',$deptName.' / '.$section);
    json_out(true,'Selected section students were cleared.');
}
if($action==='update'){
    $studentId=(int)($data['student_id']??0); $status=$data['status']??'pending'; $remarks=clean((string)($data['remarks']??''));
    if(!in_array($status,['cleared','pending','rejected'],true)) json_out(false,'Invalid status.',[],422);
    if($status!=='cleared' && $remarks==='') json_out(false,'Remarks are required when a student is uncleared or rejected.',[],422);
    $check=$pdo->prepare("SELECT id FROM users WHERE id=? AND role='student' AND course=? LIMIT 1");
    $check->execute([$studentId,$u['course']]);
    if(!$check->fetchColumn()) json_out(false,'That student is outside your assigned course.',[],403);
    $ensure=$pdo->prepare("INSERT INTO clearances(student_id,department_id,status) VALUES(?,?,'pending') ON DUPLICATE KEY UPDATE student_id=VALUES(student_id)");
    $ensure->execute([$studentId,$deptId]);
    $s=$pdo->prepare("UPDATE clearances SET status=?,cleared_at=?,remarks=?,updated_by=? WHERE department_id=? AND student_id=?");
    $s->execute([$status,$status==='cleared'?date('Y-m-d H:i:s'):null,$remarks?:null,$u['id'],$deptId,$studentId]);
    audit($pdo,$u['id'],'update_clearance',$deptName.' student '.$studentId);
    json_out(true,'Clearance updated.');
}
json_out(false,'Unknown clearance action.',[],400);
