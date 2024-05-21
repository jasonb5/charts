.PHONY: new-chart
new-chart:
  copier copy -d name=$(NAME) $(ARGS) template/ .

  pushd $(NAME); make init-chart

