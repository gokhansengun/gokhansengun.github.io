all: target3 

common_dep :
	echo "Common Dependency Running";

target1 : common_dep
	echo "Running Target1";

target2 : common_dep target1
	echo "Running Target2";

target3 : target1 target2 common_dep
	echo "Running Target3";

