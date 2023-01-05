# Pretty code distribution

enscript(1) utility can be used to process an input source code file and produce one of several formats. (The default output is postscript.)

```bash
enscript --line-numbers             \
         --highlight=javascript     \
         --color=1                  \
         --no-header                \
         --language=PostScript      \
         --output=my-app.ps         \
         my-app.js
```

Then create a PDF from the PS file:

```bash
# ps2pdf is usually included in one
# of the Ghostscript packages
ps2pdf my-app.ps
```
