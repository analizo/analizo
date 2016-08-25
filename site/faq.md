# Frequently asked questions

## Which metrics does analizo support?

Analizo supports a large number of metrics, and at each version released it may
get support for new metrics. Because of that, the safest way to know which
metrics are supported by the version you have installed is by running:

```
$ analizo metrics --list
```

The above command will list all metrics supported, both module-level and
project-level metrics. On the Analizo version 1.19.0 the supported metrics are:

```
Global Metrics:
change_cost - Change Cost
total_abstract_classes - Total Abstract Classes
total_cof - Total Coupling Factor
total_eloc - Total Effective Lines of Code
total_loc - Total Lines of Code
total_methods_per_abstract_class - Methods per Abstract Class
total_modules - Total Number of Modules
total_modules_with_defined_attributes - Total number of modules with at least one defined attributes
total_modules_with_defined_methods - Total number of modules with at least one defined method
total_nom - Total Number of Methods

Module Metrics:
acc - Afferent Connections per Class (used to calculate COF - Coupling Factor)
accm - Average Cyclomatic Complexity per Method
amloc - Average Method Lines of Code
an - Argument with 'nonnull' attribute passed null
anpm - Average Number of Parameters per Method
asom - Allocator sizeof operand mismatch
auv - Assigned value is garbage or undefined
bd - Bad deallocator
bf - Bad free
cbo - Coupling Between Objects
da - Dead assignment
dbz - Divisions by zero
df - Double free
dit - Depth of Inheritance Tree
dnp - Dereference of null pointer
dupv - Dereference of undefined pointer value
fgbo - Potential buffer overflow in call to 'gets'
lcom4 - Lack of Cohesion of Methods
loc - Lines of Code
mlk - Memory leak
mmloc - Max Method LOC
noa - Number of Attributes
noc - Number of Children
nom - Number of Methods
npa - Number of Public Attributes
npm - Number of Public Methods
obaa - Out-of-bound array access
osf - Offset free
pitfc - Potential insecure temporary file in call 'mktemp'
rfc - Response for a Class
rogu - Result of operation is garbage or undefined
rsva - Return of stack variable address
saigv - Stack address stored into global variable
sc - Structural Complexity
ua - Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)
uaf - Use-after-free
uav - Uninitialized argument value
```
