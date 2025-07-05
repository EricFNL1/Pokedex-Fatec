<?php
$conn = new mysqli("localhost", "root", "admin", "pokedex_fatec");

$id = $_POST['id'];
$nome = $_POST['nome'];
$tipo = $_POST['tipo'];
$imagem = $_POST['imagem'];

$stmt = $conn->prepare("REPLACE INTO pokemons (id, nome, tipo, imagem) VALUES (?, ?, ?, ?)");
$stmt->bind_param("isss", $id, $nome, $tipo, $imagem);
$stmt->execute();

echo json_encode(["status" => "ok"]);
?>
