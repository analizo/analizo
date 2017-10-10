tests_dir="$(dirname $0)/tests"
mkdir -p ${tests_dir}

expected_cmdline="${tests_dir}/${test_name}.cmdline"
expected_stdout="${tests_dir}/${test_name}.out"
expected_stderr="${tests_dir}/${test_name}.err"
expected_status="${tests_dir}/${test_name}.status"
