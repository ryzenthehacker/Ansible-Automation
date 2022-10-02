<?php
require_once "controllerUserData.php";
session_regenerate_id(true);

// Generate a random number 
// from 10000-99999 
$captcha = rand(10000,99999); 

// The capcha will be stored 
// for the session 
$_SESSION["captcha"] = $captcha;  

// Generate a 350x36 standard captcha image
$height = 36; 
$width = 350;   
$image_p = imagecreate($width, $height); 

// Black color 
$black = imagecolorallocate($image_p, 253, 155, 30);

// White color 
$white = imagecolorallocate($image_p, 255, 255, 255);

// Print the captcha text in the image 
// with random position & size  
$font_size = 12; 
imagestring($image_p, $font_size, 150, 10, $captcha, $white); 

imagejpeg($image_p, null, 80); 

// VERY IMPORTANT: Prevent any Browser Cache!! 
header("Cache-Control: no-store, no-cache, must-revalidate"); 

// The PHP-file will be rendered as image 
header('Content-type: image/png'); 

?>
