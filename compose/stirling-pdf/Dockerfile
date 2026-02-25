FROM frooodle/s-pdf:latest-fat

ARG EXTRA_LANGS="hin spa deu"

# Install additional languages
RUN set -e; \
    echo "Detecting tessdata path..."; \
    TESS_PATH=$(dirname $(find /usr/share -type f -name eng.traineddata | head -n 1)); \
    if [ -z "$TESS_PATH" ]; then \
        echo "ERROR: tessdata path not found" && exit 1; \
    fi; \
    echo "Detected tessdata at $TESS_PATH"; \
    for lang in $EXTRA_LANGS; do \
        if [ ! -f "$TESS_PATH/${lang}.traineddata" ]; then \
            echo "Downloading $lang"; \
            curl -fsSL \
                https://github.com/tesseract-ocr/tessdata/raw/main/${lang}.traineddata \
                -o "$TESS_PATH/${lang}.traineddata"; \
        else \
            echo "$lang already exists"; \
        fi; \
    done
