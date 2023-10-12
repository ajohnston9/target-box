<!DOCTYPE html>
<html>
<head>
<title>Jacob's Secure Ping Tool</title>
<style>
body {
  text-align: center;
}
h1 {
  text-align: center;
}
input, button {
  width: 200px;
}
button {
  margin-left: 10px;
}
pre {
  white-space: pre-wrap;
  width: 100%;
  text-align: center;
}
</style>
</head>
<body>
<h1> Jacob's Secure Ping Tool</h1>
<!-- Note to self: I can SSH in if I need to fix this, I just generated new SSH keys -->

<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
  <input type="text" name="address" placeholder="Address">
  <button type="submit">Ping</button>
</form>

<?php
if (isset($_POST['address'])) {
	$address = $_POST['address'];

	//Run the ping command in a highly secure manner
	exec("ping -c 1 $address 2>&1", $output);

	echo "<pre>";
	foreach ($output as $line) {
		echo $line . "\n";
	}
	echo "</pre>";
}
?>
</body>
</html>
