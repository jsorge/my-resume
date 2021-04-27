PHONY: pdf
pdf: ensure-pandoc ensure-wkhtmltopdf
	@chmod +x ./tools/makepdf.sh
	@./tools/makepdf.sh

PHONY: html
html: ensure-pandoc ensure-wkhtmltopdf

PHONY: ensure-pandoc
ensure-pandoc:
	@chmod +x ./tools/ensure-pandoc.sh
	@./tools/ensure-pandoc.sh

PHONY: ensure-wkhtmltopdf
ensure-wkhtmltopdf:
	@chmod +x ./tools/ensure-wkhtmltopdf.sh
	@./tools/ensure-wkhtmltopdf.sh
