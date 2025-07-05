<?php
$conn = new mysqli("localhost", "root", "admin", "pokedex_fatec");

$result = $conn->query("SELECT * FROM pokemons");

$pokemons = [];

while ($row = $result->fetch_assoc()) {
    $pokemons[] = $row;
}

echo json_encode($pokemons);
?>
