all: test

.PHONY: test

deps:
	npm i

test: deps
	flow test --cover --covercode="contracts" test/*_test.cdc
