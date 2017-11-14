Feature: analizo metrics without flags that is the default behavior

  Scenario: run analizo metrics without flags
	Given the .analizo doesn't exist
	When I run "analizo metrics t/samples/animals/java"
	Then the number of lines on file must be "127"
	Then the output must not match "_median:"
	Then the output must not match "_lower:"
	Then the output must not match "_mode:"
	Then the output must not match "_kurtosis:"

  Scenario: run analizo without configuration file
  	Given the .analizo doesn't exist
  	When I run "analizo metrics t/samples/animals/java && cat .analizo"
  	Then the file ".analizo" should exist
  	Then the output must match "npa: quantile_seventy_five"
	Then the output must match "noa: quantile_seventy_five"
	Then the output must match "sc: quantile_seventy_five"
	Then the output must match "mmloc: mean"
	Then the output must match "npm: quantile_seventy_five"
	Then the output must match "amloc: mean"
	Then the output must match "accm: quantile_seventy_five"
	Then the output must match "nom: quantile_seventy_five"
	Then the output must match "rfc: quantile_seventy_five"
	Then the output must match "acc: quantile_seventy_five"
	Then the output must match "loc: mean"
	Then the output must match "noc: quantile_ninety"
	Then the output must match "anpm: quantile_seventy_five"
	Then the output must match "lcom4: quantile_seventy_five"
	Then the output must match "dit: quantile_ninety"
	Then the output must match "cbo: quantile_seventy_five"
	Then the output must match "npa: quantile_seventy_five"

  Scenario: run analizo with a configuration file
  	Given the .analizo doesn't exist
  	Given I create a file called .analizo with the following content
"""
loc: mean
npa: quantile_ninety
sc: quantile_seventy_five
cbo: quantile_seventy_five
dit: quantile_ninety
rfc: quantile_seventy_five
amloc: mean
mmloc: mean
npm: quantile_ninety
anpm: quantile_seventy_five
nom: quantile_ninety
lcom4: mean
accm: quantile_seventy_five
noa: quantile_seventy_five
noc: mean
acc: quantile_seventy_five
"""
	When I run "analizo metrics t/samples/animals/java"
	Then the output must match "loc_mean:"
	Then the output must match "npa_quantile_ninety:"
	Then the output must match "sc_quantile_seventy_five:"
	Then the output must match "cbo_quantile_seventy_five:"
	Then the output must match "dit_quantile_ninety:"
	Then the output must match "rfc_quantile_seventy_five:"
	Then the output must match "amloc_mean:"
	Then the output must match "mmloc_mean:"
	Then the output must match "npm_quantile_ninety:"
	Then the output must match "anpm_quantile_seventy_five:"
	Then the output must match "nom_quantile_ninety:"
	Then the output must match "lcom4_mean:"
	Then the output must match "accm_quantile_seventy_five:"
	Then the output must match "noa_quantile_seventy_five:"
	Then the output must match "noc_mean:"
	Then the output must match "acc_quantile_seventy_five:"

