<?php
$path = __DIR__ . '/debs';
$cmd = "dpkg-scanpackages $path /dev/null > $path/../Packages && bzip2 -f $path/../Packages";
exec($cmd);
echo "Packages generated successfully.";
?>
