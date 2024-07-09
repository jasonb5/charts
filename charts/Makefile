.PHONY: new-chart
new-chart:
	copier copy -d name=$(NAME) $(ARGS) template/ .

.PHONY: update-template
update-template:
	find . \
		-maxdepth 1 -mindepth 1 -type d \
		-not -regex '.*\(common\|template\|cr-release\).*' \
		-exec bash -c "pushd {}; make update-template ARGS='-f'" \;

.PHONY: dep
dep:
	find . \
		-maxdepth 1 -mindepth 1 -type d \
		-not -regex '.*\(common\|template\|cr-release\).*' \
		-exec bash -c "pushd {}; make dep" \;

.PHONY: docs
docs:
	find . \
		-maxdepth 1 -mindepth 1 -type d \
		-not -regex '.*\(common\|template\|cr-release\).*' \
		-exec bash -c "pushd {}; make docs" \;

.PHONY: bump-%
bump-%:
	find . \
		-maxdepth 1 -mindepth 1 -type d \
		-not -regex '.*\(common\|template\|cr-release\).*' \
		-exec bash -c "pushd {}; make bump-$* ARGS='--only-patch --non-interactive'" \;

.PHONY: package
package:
	find . \
		-maxdepth 1 -mindepth 1 -type d \
		-not -regex '.*\(common\|template\|cr-release\).*' \
		-exec bash -c "pushd {}; make package" \;

.PHONY: upload
upload:
	find . \
		-maxdepth 1 -mindepth 1 -type d \
		-not -regex '.*\(common\|template\|cr-release\).*' \
		-exec bash -c "pushd {}; make upload GH_TOKEN=$(GH_TOKEN)" \;

.PHONY: index
index:
	git checkout gh-pages; git pull; git checkout main
	cr index \
		--config ../cr.yaml \
		--git-repo charts \
		--token $(GH_TOKEN) \
		--index-path ../index.yaml \
		--package-path ../.cr-release-packages
