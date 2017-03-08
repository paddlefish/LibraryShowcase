<?php
switch($_SERVER['REQUEST_METHOD'])
{
case 'GET':
	$myfile = fopen("high_scores.json", "r") or die("Unable to open file!");
	echo fread($myfile,filesize("high_scores.json"));
	fclose($myfile);
	break;
case 'POST':
	$score = $_POST["high_score"];
	if ($score > 0 && $score < 20000) {
		$myfile = fopen("high_scores.json", "w") or die("Unable to open file!");
		fwrite($myfile,"{\"high_score\": " . $_POST["high_score"] . " }");
		fclose($myfile);
	}
	break;
}
?>
