wget http://ftp.drupal.org/files/projects/drupal- <VERSION NUMBER> .tar.gz
tar -xzvpf drupal- <VERSION NUMBER> .tar.gz
cd drupal- <VERSION NUMBER>
mv *.* ../
cp -r includes misc modules profiles scripts themes ../
cd ..
rm -rf drupal- <VERSION NUMBER>
rm -rf drupal- <VERSION NUMBER> .tar.gz
