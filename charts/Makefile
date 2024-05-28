.PHONY: new-chart
new-chart:
	copier copy -d name=$(NAME) $(ARGS) template/ .

.PHONY: update-template
update-template:
	find . -maxdepth 1 -mindepth 1 -type d -not -regex '.*\(common\|template\|cr-release\).*' -exec bash -c "pushd {}; make update-template ARGS='-f' SKIP='-s test.yaml -s values.yaml -s CUSTOM.md'" \;
