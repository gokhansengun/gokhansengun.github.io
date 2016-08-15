all: deploy 

build :
	echo "Building the project now";

unit_test : build
	echo "Running Unit Tests";

acceptance_test : unit_test
	echo "Running Acceptance Tests";

deploy : acceptance_test
	echo "Everything is fine deploying the app";

