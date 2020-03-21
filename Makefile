PHONY: pdf
pdf: ensure-md2resume
	@chmod +x ./tools/makepdf.sh
	@./tools/makepdf.sh

PHONY: ensure-md2resume
ensure-md2resume:
	@chmod +x ./tools/ensure-md2resume.sh
	@./tools/ensure-md2resume.sh

PHONY: example
example:
	./vended/markdown-resume/bin/md2resume pdf \
		./vended/markdown-resume/examples/source/sample.md \
		./vended/markdown-resume/examples/output/
