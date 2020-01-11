MC's Vim / NeoVim setup
=======================
[MC's](https://github.com/hash-bang) personal VIM / NeoVIM setup.

**Layout:**

* `vimrc` - Main loading file
* `autoload/*` - Autoloaded modules, Pathogen module loader lives here
* `autoload/colorschemes/lightline/*` - Custom lightline themes
* `bundles/*` - External bundled modules (loaded by Pathogen)
* `colors/*` - Misc color schemes not tracked via bundled modules
* `doc/*` - Misc documentation not tracked via bundled modules
* `mc-snippets/*` - Various [UltiSnips](https://github.com/sirver/UltiSnips) managed snippet files
* `plugin/*` - Misc plugins not tracked by bundled modules
* `spell/*` - Custom dictionaries
* `syntax/*` - Misc Syntax definition files not tracked via bundled modules
* `undo/*` - Undo files. Not tracked via Git


Installation
============
This assumes you want to keep your Vim install scripts in `~/.vim` and all submodule bundles are required:

```
# Clone repo and all bundles
cd
git clone --recursive git@github.com:hash-bang/vimrc.git .vim

# Setup NeoVIM to point to the same init file
mkdir .config/nvim 2>/dev/null
ln -s .vim/init.vim .config/nvim/init.vim

# Update all remote plugins
nvim +:UpdateRemotePlugins +:quit
```
