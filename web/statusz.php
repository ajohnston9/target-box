<!DOCTYPE html>
<html>
<head>
<title>Machine Status</title>
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
<h1> Machine Status </h1>

<li><b>Time:</b> <?php echo exec("date") ?></li>
<li><b>Uptime:</b> <?php echo exec("uptime") ?></li>
<li><b>CPU:</b> <?php echo exec("top -bn1 | grep '%Cpu' | cut -d: -f2") ?></li>
<li><b>Memory:</b> <?php echo exec("top -bn1 | grep 'MiB Mem' | cut -d: -f2") ?></li>


</body>
</html>
