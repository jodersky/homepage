target=_site

target_files=\
	$(patsubst %,$(target)/%, $(shell find assets -type f)) \
	$(patsubst %,$(target)/%, $(shell find projects -type f)) \
	$(patsubst %,$(target)/%, $(shell find talks -type f)) \
	$(target)/404.html \
	$(target)/CNAME \
	$(target)/cv.pdf \
	$(target)/index.html \
	$(target)/keybase.txt \
	$(target)/projects.html \
	$(target)/talks.html

all: $(target_files)

publish: $(target_files)
	git -C $(target) init
	git -C $(target) add .
	git -C $(target) commit -m "Publish website" || true
	git -C $(target) push -f git@github.com:jodersky/website master:gh-pages

clean:
	rm -rf $(target)

$(target)/assets/%: assets/%
	@mkdir -p $(@D)
	cp $< $@

$(target)/%.html: %.html layout.pandoc.html
	@mkdir -p $(@D)
	pandoc \
		--standalone \
		--template=layout.pandoc.html \
		--from=markdown+yaml_metadata_block-native_divs-native_spans \
		--to=html5 \
		--variable=base_path:$(shell realpath --relative-to=$(shell dirname $<) .) \
		--variable=navbar_$(patsubst %.html,%,$<):true \
		--out=$@ $<

$(target)/%.html: %.md layout.pandoc.html
	@mkdir -p $(@D)
	pandoc \
		--standalone \
		--template=layout.pandoc.html \
		--from=markdown \
		--to=html5 \
		--variable=base_path:$(shell realpath --relative-to=$(shell dirname $<) .) \
		--variable=navbar_$(patsubst %.md,%,$<):true \
		--out=$@ $<

$(target)/%: %
	@mkdir -p $(@D)
	cp $< $@

$(target)/talks/scala-channels.html: talks/scala-channels.html
	@mkdir -p $(@D)
	cp $< $@

$(target)/talks/project-condor.html: talks/project-condor.html
	@mkdir -p $(@D)
	cp $< $@


.PHONY: all clean publish
