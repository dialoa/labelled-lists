FROM pandoc/latex:latest

# If we need LaTeX packages not included in pandoc/latex:latest
# We need to point out the version it uses (here is for 2022)
# RUN tlmgr option repository https://ftp.tu-chemnitz.de/pub/tug/historic/systems/texlive/2022/tlnet-final \
#     && tlmgr install \
#     package1 \
#     package2

ENTRYPOINT [ "/usr/local/bin/pandoc" ]