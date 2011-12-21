if (system('which cucumber >/dev/null') == 0) {
  print "I: Running acceptance tests with cucumber ...\n";
  system('ruby --version');
  system('echo -n "cucumber " ;cucumber --version');
  exec('cucumber --format progress --tags ~@wip features/');
} else {
  print "W: cucumber not found, not running acceptance tests.\n";
}
