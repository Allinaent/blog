#!/bin/bash
export pandoc_ver=2.18
wget https://github.com/jgm/pandoc/releases/download/$pandoc_ver/pandoc-$pandoc_ver-linux-amd64.tar.gz
tar -xzvf pandoc-$pandoc_ver-linux-amd64.tar.gz
mv pandoc-$pandoc_ver/bin/pandoc .
curl -Lo hugo-bin https://github.com/SDLMoe/hugo/releases/latest/download/hugo

chmod +x hugo-bin
chmod +x pandoc

PATH=$(pwd):$PATH ./hugo-bin --minify --gc
