#! /usr/bin/env bash

TMP='./tmp'
PROCESSED_MARKDOWN="$TMP/resume.html"
PROCESSED_HTML="$TMP/processed-output.html"
TEMPLATES="./template"

if [ ! -d $TMP ]; then
	mkdir $TMP;
else
	rm -rf $TMP
	mkdir $TMP
fi;

# convert the markdown to HTML for resume content
./vended/pandoc -o $PROCESSED_MARKDOWN Jared-Sorge-Resume.md

# read in the converted markdown, apply to the HTML template
TEMPLATE=$(cat ./template/resume-template.html)

STYLES=$(cat $TEMPLATES/resume.css)
TEMPLATE="${TEMPLATE/'{{{style}}}'/$STYLES}"

CONVERTED=$(cat $PROCESSED_MARKDOWN)
TEMPLATE="${TEMPLATE/'{{{resume}}}'/$CONVERTED}"


# save the HTML template to disk
echo $TEMPLATE > $PROCESSED_HTML

# convert the final HTML to the PDF
./vended/wkhtmltopdf $PROCESSED_HTML Jared-Sorge-Resume.pdf
