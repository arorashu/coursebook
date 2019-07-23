# Find all tex files one directory down
TEX=$(shell find . -path "./.git*" -prune -o -type f -iname "*.tex" -print)
MAIN_TEX=main_wrapper.tex
PDF_TEX=$(patsubst %.tex,%.pdf,$(MAIN_TEX))
MAIN_OUT=main.pdf
BASE=$(patsubst %.tex,%,$(MAIN_TEX))
OTHER_FILES=$(addprefix $(BASE),.aux .log .synctex.gz .toc .out .blg .bbl .glg .gls .ist .glo)
BIBS=$(shell find . -maxdepth 2 -mindepth 2 -path "./.git*" -prune -o -type f -iname "*.bib" -print)
LATEX_COMMAND=pdflatex -quiet -synctex=1 -interaction=nonstopmode $(MAIN_TEX) > /dev/null 2>&1
OTHER=$$(find . -iname *aux) $$(find . -iname *bbl) $$(find . -iname *blg)
ORDER_TEX=order.tex
ORDER_TEX_DEP=order.yaml

TEX_ORDER=$(shell sh -c "cat order.yaml | sed 's/^- //'")
CHAPTER_PDF=$(patsubst %,%.pdf,$(TEX_ORDER))

.PHONY: all
all: $(MAIN_OUT) chapters
	-@latexmk -c
	-@rm *aux *bbl *glg *glo *gls *ist *latexmk *fls
	-@rm **/*aux **/*bbl **/*glg **/*glo **/*gls **/*ist **/*latexmk **/*fls

.PHONY: chapters
chapters: $(CHAPTER_PDF)

.PHONY: debug
debug: $(PDF_TEX)-debug

$(ORDER_TEX): $(ORDER_TEX_DEP)
	python3 _scripts/gen_order.py $^ > $@

$(CHAPTER_PDF): %.pdf: %.tex
	echo '\\let\\cleardoublepage\\clearpage' > $@.tmp
	echo "\includeonly{$(basename $^)}\input{$(MAIN_TEX)}" >> $@.tmp
	-latexmk -interaction=nonstopmode -quiet -f -pdf -jobname="$@" $@.tmp 2>&1 >/dev/null
	@mv $@.pdf $@
	@ls $@ > /dev/null
	-@rm $@.tmp

$(MAIN_OUT): $(TEX) $(MAIN_TEX) $(BIBS) Makefile $(ORDER_TEX)
	-@latexmk -quiet -interaction=nonstopmode -f -pdf $(MAIN_TEX)
	@ls $(PDF_TEX) > /dev/null
	@mv $(PDF_TEX) $(MAIN_OUT)
	@echo "Finished"

$(PDF_TEX)-debug: $(TEX) $(MAIN_TEX) $(BIBS) Makefile
	-@latexmk -interaction=nonstopmode -f -pdf $(MAIN_TEX) > latexmk.out
	@mv $(PDF_TEX)-debug $(MAIN_OUT)

.PHONY: clean
clean:
	-@rm $(PDF_TEX) $(OTHER_FILES) $(OTHER)



