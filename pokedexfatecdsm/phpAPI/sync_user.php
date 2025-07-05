<?php
$conn = new mysqli("localhost", "root", "admin", "pokedex_fatec");

$id = $_POST['id'];
$email = $_POST['email'];
$senha = $_POST['senha'];

$stmt = $conn->prepare("REPLACE INTO usuarios (id, email, senha) VALUES (?, ?, ?)");
$stmt->bind_param("iss", $id, $email, $senha);
$stmt->execute();

echo json_encode(["status" => "ok"]);
?>
