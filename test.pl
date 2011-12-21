if (system('which cucumber >/dev/null') == 0) {
  print "I: Running acceptance tests with cucumber ...\n";
  system('ruby --version');
  system('echo -n "cucumber " ;cucumber --version');
  system('cucumber --format progress --tags ~@wip features/') == 0 or exit(1);
} else {
  print "W: cucumber not found, not running acceptance tests.\n";
}
