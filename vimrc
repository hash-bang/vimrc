" MC's overly complex VIM / NeoVIM config file
" God help you if you're using this
"
" @author Matt Carter <m@ttcarter.com>
" @url https://github.com/hash-bang/vimrc

" Shorthand global config switches
let g:switch_wakatime=0 " Enable wakatime Plugin

" Color scheme options
let g:switch_colorscheme = 'nord' " Selected color scheme, must match an entry within `Plugins: COLOR SCHEMES`

" ---------------------------------
" Below this line - here be dragons
" ---------------------------------


" Functions {{{
function! GetVisual() range
	let reg_save = getreg('"')
	let regtype_save = getregtype('"')
	let cb_save = &clipboard
	set clipboard&
	normal! ""gvy
	let selection = getreg('"')
	call setreg('"', reg_save, regtype_save)
	let &clipboard = cb_save
	return selection
endfunction
" }}}

" HeathenTab() - Work where indenting = tab {{{
function HeathenTab()
	set smarttab
	set shiftwidth=8
	set softtabstop=0
	set noexpandtab
	echo "Heathen (Tab) mode"
endfunction
" }}}

" Heathen2s() - Work where indenting = 2 spaces {{{
function Heathen2s()
	set smarttab
	set shiftwidth=2
	set softtabstop=2
	set expandtab
	echo "Heathen (2 space) mode"
endfunction
" }}}

" Heathen4s - Work where indenting = 4 spaces {{{
function Heathen4s()
	set smarttab
	set shiftwidth=4
	set softtabstop=4
	set expandtab
	echo "Heathen (4 space) mode"
endfunction
" }}}

" Book() - Display text in a readable book format {{{
function Book()
	se nonu
	se lbr
	se display=lastline
	se nohls
endfunction
" }}}

" GitSplit() Switch to Git comment mode for Git commit types {{{
function GitSplit()
	se splitbelow
	new
	silent read!git diff --staged 2>/dev/null
	goto 1
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal noswapfile
	se ft=git-status

	" Move to new window
	wincmd k
endfunction

let g:git_diff_spawn_mode = 1
au! BufRead,BufNewFile COMMIT_EDITMSG call GitSplit()
" }}}

" CleanTVSeries() - Try to tidy up `vidir` output for TV series {{{
function! CleanTVSeries()
	" Remove x264-(AUTHOR) stuff
	silent %s/x264-.*\.//g

	" Inline info
	silent %s/HDTV\.//g
	silent %s/PROPER\.//g
	silent %s/UNCUT\.//g
	silent %s/REPACK\.//g
	silent %s/720p\|1080p\|x264//g
	silent %s/BluRay//g
	silent %s/YIFY\|anoXmous_//g

	silent %s/\.\{2,\}/./g

	" Tidy up series S01E01 -> 1x01
	silent %s/S0\(\d\)E\(\d\d\)\./\1x\2\./i
endfunction
map <F4> :call CleanTVSeries()<CR>
" }}}
" }}}
" General Options {{{
set encoding=utf-8
set nocompatible " Disable vi-compatibility

" Turn off mouse functionality
set mouse=
" Turn on Line numering
set nu
" Enable case-insesitive matching
set ic
" Enable smart-casing (use of upper char overrides case-insensitive)
set scs
" Disable Auto-indent as its almost never right
set noai
" Smart indent (drop back when using })
set si
" Include <> and "" as a bracket pairing
set mps=(:),{:},[:],<:>,":"
" Apply /g by default on all replacements
set gdefault
" Hilight search terms
set hls
" Colorize
syntax on
" Wildcard file selection
set wmnu
" Backspace always
set bs=2
" Hilight the next match as we type
set is
" Lazy redraw - prevents flickering during Macros
set nolazyredraw
" Ignore Python compiled files and backup files
set wig=*.pyc,*.pyo,*.*~
" Force all swap files into the tmp directory
set dir=/tmp
" Enable mode lines (# vim:ft=blah for example)
set modeline
" Make Shift tab complete file names in insert mode
inoremap <S-Tab> <C-X><C-F>
" Disable backup files before overwrite (i.e. something.txt~ files)
set nowb
" Enable cursor line highlighting
set cursorline
" Keep at least 5 lines above/below
set scrolloff=5
" Keep at least 5 lines left/right
set sidescrolloff=5
" Enable undo files
set undofile
set undodir=$HOME/.vim/undo
" Auto save
set autowrite
" Split vertical windows to the right
set splitright
" Dont wrap searching
set nows
" Set minimal window size to 0 (when using Ctrl+W+_ this minimizes all windows to one line)
set wmh=0

" Set tab width
set tabstop=4
set shiftwidth=4

" Set the command line height to auto-hide
set cmdheight=0
" }}}
" File browser (netrw) Options {{{
" Set default layout to long mode (name, size, date)
let g:netrw_liststyle=1
" }}}
" File Types {{{
autocmd BufRead,BufNewFile *.PAS set ft=pascal
autocmd BufRead,BufNewFile *.pas set ft=pascal
autocmd BufRead,BufNewFile *.ng set ft=vue
autocmd BufRead *.txt set ft=
autocmd BufRead NOTES set ft=todo
autocmd BufRead MEETINGS set ft=todo
autocmd BufRead *.TODO set ft=todo
autocmd BufRead .env* set ft=dotenv

" Smart indending for Python
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufRead .xfile set ft=xfile

" Remove all whitespace in certain files
autocmd BufWritePre *.css %s/\s\+$//e
autocmd BufWritePre *.js %s/\s\+$//e
autocmd BufWritePre *.json %s/\s\+$//e
autocmd BufWritePre *.html %s/\s\+$//e
" }}}
" File paths {{{
" Set the PWD to the current buffer when changing
" Which allows relative path addressing
set autochdir
" }}}
" Folding {{{
" Use {{{ and }}} to denote a fold in a document
set foldmethod=marker
set commentstring=//\ %s

" NOTE: This function gets overriden by the pretty-fold plugin anyway and is
"       maintained here for historical reference / fallback
function! FoldText()
	let line = getline(v:foldstart)
	let folded_line_num = v:foldend - v:foldstart
	let line_text = substitute(line, '\s*{\+\s*$', '', 'g')
	let line_text = substitute(line_text, '^\s*\("\|\/\|#\|<!--\|*\)\+', '', 'g') " starting comments - speachmark (VIMscript) | hash (Bash) | comment (HTML) | asterisks (CSS)
	let line_text = substitute(line_text, '\(-->\)\+\s*$', '', 'g') " closing comments - comment (HTML)
	let line_text = substitute(line_text, '\s*{\+\s*$', '', 'g') " General fold markers (tripple open braces)

	let fillcharcount = winwidth('%') - len(line_text) - len(folded_line_num) - 12
	return '  '. line_text . repeat(' ', fillcharcount) . ' (' . folded_line_num . ')'
endfunction
set foldtext=FoldText()
set fillchars=fold:.
" }}}
" Movement {{{
" Allow cursor to move one more character off the end of the line
set virtualedit=onemore
" }}}
" Alias map (Common mistypes) {{{
" Mistakes for :wpa
command -nargs=0 Wqa :wqa!
cnoreabbrev qwa :wqa!
" }}}
" Key Map {{{
" Key Fixes {{{
" Use Perl RegExps
"nnoremap / /\v
"vnoremap / /\v

" Map ; -> :
nnoremap ; :
vnoremap ; :

" Map J to join lines without spaces
nnoremap J JlF x

" Map Alt+Arrow to mean BOL, EOL movement
map <M-Left> ^
map <M-Right> $

" Map Ctrl+Up/Down to Page Up/Down
map <C-Up> [5~
map <C-Down> [6~
" }}}
" Leaders {{{
" Change leader key to ,
let mapleader = ","
" Leader W - Stip all white space
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Leader <speachmark> - Change surrounding ' to "
map <leader>" cs'"
" Leader <quotemark> - Change surrounding " to '
map <leader>' cs"'

" VimDiff controls {{{
" Leader '>' - (Used in vimdiff) Copy right file to left, save and quit
map <leader>> gglggyGh"_dGpggdd
" Leader '<' (Used in vimdiff) Use left, save and quit (really just an alias to :wqa)
map <leader>< :wqa <CR>
" Leader '/' - Update the diff image
map <leader>/ :diffupdate <CR>
" }}}
" }}}
" Clipboard functionality {{{
" Alt-Y yanks to X clipboard
vmap <m-y> "+yi<ESC>

" Alt-D kills to X clipboard
vmap <m-d> "+c<ESC>

" Alt-P pastes from X clipboard
vmap <m-p> "+p<ESC>
map <m-p> "+p<ESC>

" F9 toggles paste friendly (VIM only, NVIM has this automatic)
se pt=<F9>
" }}}
" Change {{{
" `` - change previous ' on line to ` - used to correct the current single speachmark to a backtick when realizing you need ${} halfway though a JS string
map `` mz?'<cr>r``z
" }}}
" Folds {{{
" z + {up,down} - navigate folds
map z<up> zk
map z<down> zj

" ]z [z - navigate folds like spell
map ]z zj
map [z zk
" }}}
" File list (really "buffer") naivgaton {{{
nmap mm :n<CR>
" }}}
" File types (gt*) {{{
nmap gtb :se ft=sh<CR>
nmap gtc :se ft=css<CR>
nmap gth :se ft=html<CR>
nmap gtj :se ft=javascript<CR>
nmap gts :se ft=sql<CR>:se nowrap<CR>
nmap gto :se ft=json<CR>
nmap gtv :se ft=vue<CR>

" KLUDGE: Disable Treesitter until AOS moves to Doop@3
map gtx :TSDisable highlight<CR>
" }}}
" Movement {{{
" `T` - move to last character within line
noremap T $F
" }}}
" Pasting {{{
" Map `gp` to select last pasted text
" gv / gpp - select previously pasted text (`gp` can't be remapped for some reason)
nnoremap <expr> gpp '`[' . getregtype()[0] . '`]'
" }}}
" Saving {{{
nmap XX :w!<CR>
" }}}
" Searching {{{
" ,n - search from top
map ,n ggn
" }}}
" Tabs {{{
" Pop current window / buffer out into new tab
" Ctrl+S&m/"/" - Move this window pane to new tab
map <C-s>m :tabedit %<CR>
map <C-s>/ :tabedit %<CR>
" Ctrl+S&n - Move to next tab
map <C-s>n :tabnext<CR>
" CTRL+S&N/P - Move to previous tab
map <C-s>N :tabprevious<CR>
map <C-s>p :tabprevious<CR>
" CTRL+S&c/x - Close tab
map <C-s>c :tabclose<CR>
map <C-s>x :tabclose<CR>
" }}}
" Visual mode {{{
" Press @q in visual mode to run that macro on all selected lines
vmap @q :normal @q<CR>
" }}}
" Windows {{{
" <C-W>S (capital S) opens UNDER current window
map <c-w>S :split<cr><c-w>j

" <C-W>V (capital V) opens TO RIGHT of current window
map <c-w>V :vsplit<cr><c-w>h

" <C-W>P Closes all preview windows
map <c-w>p :pclose<cr>
" }}}
" Windows > Terminal {{{
" Spawn split terminal with c-t / c-w-t or with vsplit c-y c-w-y
if has('nvim')
	nmap <c-t> :split<CR>:term<CR>
	nmap <c-w>t :split<CR>:term<CR>

	nmap <c-y> :vsplit<CR>:term<CR>
	nmap <c-w>y :vsplit<CR>:term<CR>

	" Allow Esc to escape
	tnoremap <esc> <c-\><c-n>

	" Allow window focus moving
	tnoremap <c-w> <c-\><c-n><c-w>
endif
" }}}
" Misc fixes {{{
" Turn off bloody Ex mode
nnoremap Q <nop>
" Sudo to write
cmap w!! w !sudo tee % >/dev/null
" c" = Change inside "
map c" ci"
" c' = Change inside '
map c' ci'
" cz' = Change surrounding " -> '
map cz' cs"'
" cz" = Change surrounding ' -> "
map cz" cs'"
" c< = Change inside <
map c< ct<
map c> ct<
" Ctrl+D Insert date in big-endian format
map <C-D> :read !date +\%Y-\%m-\%d<CR>$a
imap <C-D> :read !date +\%Y-\%m-\%d<CR>$a
" Ctrl+H switch to hex mode
map <C-H> :%!xxd<CR>
"  Ctrl+K Insert randomly generated 10 character password
map <C-K> :read !pwgen 10<CR>
" ,l Toggle concel
map <leader>l :exec &conceallevel ? "set conceallevel=0" : "set conceallevel=1"<CR>
" F3 - Replace active RegExp with nothing
map <F3> :%s///<CR>
" F4 - Replace active RegExp with a prompted replacement
map <F4> :%s//
vmap <F4> y/<C-R>"<CR>:%s//
" F5 - Reload the current file
map <F5> :e! %<CR>
" F6 - Reload the current file as a VimScript (e.g. .vimrc)
map <F6> :source %<CR>:echo "Resourced " . bufname()<CR>
" F7 - Set JavaScript mode
map <F7> :se ft=javascript<CR>
" F8 to give a char count for a selected visual block
map <F8> :echoe "Str Length:" . strlen(GetVisual())<CR>gv
" F12 - Disable hilighting
map <F12> :set nohls<CR>
imap <F12> <ESC>:set nohls<CR>
" QQ to just quit
map QQ <ESC>:qa <CR>
" GL - Toggle line numbers
map gl :set number! <CR>
" {{ | }} - Move around functions
map }} ]}
map {{ [{
" Ctrl + P will paste + auto indent
map <C-P> p==

" Enable Heathen-Tab mode
map ght :call HeathenTab()<CR>
" Enable Heathen-2S mode
map gh2 :call Heathen2s()<CR>
" Enable Heathen-4S mode
map gh4 :call Heathen4s()<CR>

" map Z- to toggle spelling
map z- :se spell!<CR>

" Proper casing using the '!' key (not counting words beginning with '.' - so .mp3 is not capitalised to .Mp3)
vmap ! :s/\([^\.]\)\<\([a-z]\)\([a-z]*\)/\1\U\2\E\3/gi <CR>

" Ctrl +/- resizes quickly
map + <C-W>+
map - <C-W>-

" Assign CTRL+S as ASPELL check
" map <C-S> :w<CR>:!aspell -c --dont-backup "%"<CR>:e! "%"<CR>

" Ctrl|Shift + Arrow Movement
nmap O1;5B <C-E>
nmap O1;2B <C-E>
nmap O1;6B <C-E>
nmap O1;5A <C-Y>
nmap O1;2A <C-Y>
nmap O1;5C <W>
nmap O1;2C <W>
nmap O1;5D <B>
nmap O1;2D <B>

" System Clipbaord {{{
" Helper functions {{{
function GetSelectedText()
	normal gv"xy
	let result = getreg("x")
	normal gv
	return result
endfunction

function Clipboard() range
	echo system('echo '.shellescape(GetSelectedText()).' | sed "s/\\\\$//g" | xsel -ib')
endfunction
" }}}

" Associate helper function 'Clipboard' -> 'call Clipboard()'
command -range=% -nargs=0 Clipboard :<line1>,<line2>call Clipboard()
" Copy to clipboard in visual mode - capital Y
vmap Y :Clipboard<CR>
" YY to copy all to clipboard
map YY :%!xsel -ib<CR>u
" }}}

" Map [[ and ]] to start-of and end-of file movement
nmap [[ gg
nmap ]] G

" FIX: Remap [[ + ]] even if the syntax file tries to screw with them {{{
function! s:FixSquareBrackets()
	silent! unmap <buffer> [[
	silent! unmap <buffer> ]]
endfun

" Attach to the "entering the buffer the first time" hook and run the fixer
autocmd BufEnter * call s:FixSquareBrackets()
" }}}

" Map g/ to global search (i.e. top-of-doc + search)
map g/ gg/

" OTHER MAPS
" --- Yankring ---
" 	Ctrl-P (after paste) - move backwards though YankRing

" --- Surround --
"	cs'" - Change all surrounding ' -> "
"	ds" - Delete surrounding "s

" --- EMMET ---
" <C-Y>, - Apply Emmet formatting to text at left of cursor
" <C-Y>n - Jump to next editable HTML point
" <C-Y>N - Jump to previous editable HTML point
" <C-Y>k - Delete tag under cursor
let g:user_emmet_leader_key='<C-Y>'
imap <C-L> <C-Y>,


" MISC HACKS

" Ctrl_W N creates new (vertical window) - I don't know why this is not this way by default
nmap <C-W>N :vnew<CR>

" Clever Indenting of visual blocks (i.e. don't escape after each operation)
" - Map for < and > (VI Like)
vnoremap > >gv
vnoremap < <gv

" visual searching (// to activate)
vmap // y/<C-R>"<CR>
vmap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>
" }}}
" Specific host overrides {{{
"if hostname() == 'Shark'
"	cmap \ [6~
"endif
" }}}
" }}}

" Plugins: START {{{
call plug#begin('~/.vim/plugged')
" }}}
" Plugins: COLOR SCHEMES {{{
" Set 256 Colors (for consoles that can handle it)
set termguicolors
set t_Co=256

" Color scheme switches {{{
let g:switch_colorscheme_patch_cursor = 0 " Repair cursor coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_conceal = 0 " Repair conceal coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_lightline = 0 " Repair lightline coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_visual = 0 " Repair visual coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_contrast_folds = 0 " Repair folds in high-contrast mode
" }}}

" This entire section is pretty much a multiplexor based on switch_colorscheme

" Plug area (so everything keeps updated)
Plug 'habamax/vim-bronzage'
Plug 'nightsense/cosmic_latte'
Plug 'morhetz/gruvbox'
Plug 'embark-theme/vim'
Plug 'sainnhe/everforest'
Plug 'fenetikm/falcon'
Plug 'savq/melange'
Plug 'EdenEast/nightfox.nvim'
Plug 'shaunsingh/nord.nvim'
Plug 'jacoborus/tender.vim'
Plug 'folke/tokyonight.nvim'

" Overrides based on colorscheme
if switch_colorscheme == 'anotherdark'
	" Another dark is a built in anyway
	let g:switch_colorscheme_patch_lightline = 1
	let g:switch_colorscheme_patch_visual = 1
	colorscheme anotherdark
elseif switch_colorscheme == 'falcon'
	let g:switch_colorscheme_patch_cursor = 1
elseif switch_colorscheme == 'nightfox'
	let g:switch_colorscheme_patch_conceal = 1
elseif switch_colorscheme == 'nord'
	let g:switch_colorscheme_patch_contrast_folds = 1
	let g:switch_colorscheme_patch_conceal = 1
elseif switch_colorscheme == 'tender'
	let g:switch_colorscheme_patch_conceal = 1
elseif switch_colorscheme == 'zenburn'
	let g:zenburn_high_Contrast=1
	let g:zenburn_old_Visual=1
	let g:zenburn_alternate_Visual=1
	colorscheme zenburn
endif
" }}}
" Plugins: GENERAL SYNTAX {{{
Plug 'LeonB/vim-nginx'
Plug 'hash-bang/vim-vue'
Plug 'hash-bang/vim-todo'
Plug 'projectfluent/fluent.vim'
" }}}
" Plugin: SYNTAX / vim-markdown {{{
Plug 'plasticboy/vim-markdown'
" Disable section folding
let g:vim_markdown_folding_disabled = 1

" Disable concealing
let g:vim_markdown_conceal = 0
" }}}

" Plugin: Actually - Correct mistyped file names {{{
Plug 'mong8se/actually.nvim'

" Fancier windows
Plug 'stevearc/dressing.nvim'
" }}}
" Plugin: Commentry - Use # to toggle line comments {{{
Plug 'tpope/vim-commentary'
" map # (visual mode) to comment out selected lines
vmap # gc
" }}}
" Plugin: Conoline - CUL line highlight for current window {{{
Plug 'miyakogi/conoline.vim'

let g:conoline_auto_enable = 1
" }}}
" Plugin: Emmet - Use <C-Y> to transform CSS under cursor to HTML via Emmet {{{
" Ctrl+Y , is default binding
Plug 'mattn/emmet-vim'
" }}}
" Plugin: Eregex - PCRE / Perl RegEx (Use %S to replace ,/ to toggle) {{{
" NOTE: Use :%S// to replace (upper case S)
Plug 'othree/eregex.vim'

" Disable by default so other plugins work (as-you-type syntax highlighting) use ,/ to enable
let g:eregex_default_enable = 0

" Toggle using ,/
nnoremap <leader>/ :call eregex#toggle()<CR>
" }}}
" Plugin: Fugitive {{{
Plug 'tpope/vim-fugitive'
" }}}
" Plugin: FZF - Bind ,g to FZF finder, ,r to RipGrep {{{
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Map ,g to open FZF file finder
map ,g :Files<cr>

" Map ,r to RipGrep via FZF
map ,r :Rg<cr>
" }}}
" Plugin: GitSigns - Screen-side Git Indicators (replaces GitGutter) {{{
" @url https://github.com/lewis6991/gitsigns.nvim
Plug 'lewis6991/gitsigns.nvim', {'done': 'lua require(''gitsigns'').setup()'}

" map ]h / ]h to jump to next / previous hunk
map ]h :lua require('gitsigns.actions').next_hunk()<CR>
map [h :lua require('gitsigns.actions').prev_hunk()<CR>
" }}}
" Plugin: GV - Git commit tree view with :GV {{{
" :GV - Show all commits
" :GV! - Show commits effecting the current file
Plug 'junegunn/gv.vim'
" }}}
" Plugin: HL_Match_area - highlight areas within delimeters {{{
Plug 'rareitems/hl_match_area.nvim', {'done': 'call s:ConfigHLMatchArea()'}

function s:ConfigHLMatchArea()
lua <<EOF
require('hl_match_area').setup({
	n_lines_to_search = 100, -- how many lines should be searched for a matching delimiter
	highlight_in_insert_mode = true, -- should highlighting also be done in insert mode
	delay = 100, -- delay before the highglight
})

vim.api.nvim_set_hl(0, 'MatchArea', {bg="#212e3f"})
EOF
endfunction
" }}}
" Plugin: Hop - Quick navigation via `` (Replaces EasyMotion) {{{
Plug 'phaazon/hop.nvim', {'done': 'call s:ConfigHop()'}
function s:ConfigHop()
lua <<EOF
require('hop').setup({
	uppercase_labels = false,
})
EOF

	map `` :HopWord<cr>

	" H in visual mode
	vmap h <CMD>HopWord<CR>

	" Various combinations
	map `q :HopAnywhere<CR>
	map `v :HopLine<CR>
	map `c :HopChar1<CR>
	map `0 :HopWordCurrentLine<CR>
	map `1 :HopLine<CR>
	map `2 :HopWordCurrentLine<CR>
	map `$ :HopWordCurrentLine<CR>
	map `^ :HopWordCurrentLine<CR>
	map `l :HopWordCurrentLine<CR>
	map `L :HopChar1CurrentLine<CR>

	vmap `` :
endfunction
" }}}
" Plugin: Illuminate - Highlight keyword under cursor, move with <a-n> / <a-N> {{{
Plug 'RRethy/vim-illuminate', {'done': 'call s:ConfigIlluminate()'}

function s:ConfigIlluminate()
lua <<EOF
require('illuminate').configure({
	-- See https://github.com/RRethy/vim-illuminate
	delay = 300,
})

vim.keymap.set('n', '<a-n>', require('illuminate').goto_next_reference)
vim.keymap.set('n', '<a-N>', require('illuminate').goto_prev_reference)
EOF
endfunction
" }}}
" Plugin: Increment - Improve default incrementing functionality with visual selects {{{
" Use [inc-type] + <c-a> to increment
Plug 'triglav/vim-visual-increment'

" Ctrl - A - Increment all Visual area numbers per-line (zero padded)
vnoremap <c-a> :Inc<CR>
" Ctrl - S - Increment all Visual area numbers per-line (no padding)
vnoremap <c-s> :IncN<CR>
" }}}
" Plugin: Indent Jump - Jump around with Ctrl+{Up,Dn} {{{
Plug 'w3bdev1/IndentJump.vim'
nmap <c-up> <Plug>(Indent-Jump-Backward)
nmap <c-down> <Plug>(Indent-Jump-Forward)
" }}}
" Plugin: Indent-O-Matic - Detect indents from context {{{
Plug 'Darazaki/indent-o-matic', {'done': 'call s:ConfigIndentOMatic()'}
function s:ConfigIndentOMatic()
lua <<EOF
	require('indent-o-matic').setup {
		-- Number of lines without indentation before giving up (use -1 for infinite)
		max_lines = 100, -- Default (2048)

		-- Space indentations that should be detected
		standard_widths = { 2, 4, 8 },

		-- Skip multi-line comments and strings (more accurate detection but less performant)
		skip_multiline = true,
	}
EOF
endfunction
" }}}
" Plugin: Javascript - Nicer Javascript syntax {{{
Plug 'pangloss/vim-javascript'
let g:javascript_conceal = 1
let g:javascript_conceal_function = "λ"
let g:javascript_conceal_null = "ø"
let g:javascript_conceal_this = "◉"
let g:javascript_conceal_ctrl = "◈"
let g:javascript_conceal_return = "∴"
let g:javascript_conceal_undefined = "¿"
let g:javascript_conceal_NaN = "ℕ"
let g:javascript_conceal_prototype = "¶"
let g:javascript_conceal_static = "•"
let g:javascript_conceal_super = "Ω"
let g:javascript_conceal_question = "¿"
let g:javascript_conceal_arrow_function = "🡆"
let g:javascript_conceal_noarg_arrow_function = "🞅"
let g:javascript_conceal_underscore_arrow_function = "🞅"
set conceallevel=1

let g:javascript_plugin_jsdoc = 1
" }}}
" Plugin: JSON - Nicer JSON syntax {{{
Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal = 0
" }}}
" Plugin: LastPlace - Return to the last editing position on open {{{
Plug 'ethanholz/nvim-lastplace', {'done': 'call s:ConfigLastPlace()'}

function s:ConfigLastPlace()
lua <<EOF
require('nvim-lastplace').setup({
	lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
	lastplace_ignore_filetype = {"gitcommit", "gitrebase", "svn", "hgcommit", "todo"},
	lastplace_open_folds = true,
})
EOF
endfunction
" }}}
" Plugin: Lualine - Statusline display {{{
Plug 'nvim-lualine/lualine.nvim', {'done': 'call s:ConfigLualine()'}
Plug 'kyazdani42/nvim-web-devicons'

function s:ConfigLualine()
lua <<EOF

require('lualine').setup({
	options = {
		icons_enabled = true,
		theme = 'auto',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
		always_divide_middle = true,
	},
	sections = {
		lualine_a = {
			'mode'
		},
		lualine_b = {
			'branch',
			'diff',
			'diagnostics',
		},
		lualine_c = {
			{'filetype',
				icon_only = true,
				separator = '', -- Join with next section
				padding = {left = 1},
			},
			{'filename',
				padding = {left = 1, right = 0},
				path = 1, -- 0 = Basename, 1 = Relative path, 2 = Absolute path
				symbols = {
					modified = ' [+]',
					readonly = ' [-]',
					unnamed = '[No Name]',
				}
			},
		},
		lualine_x = {
			{'mode', -- Show RECORDING notice optionally
				cond =
					function()
						local recordChar = vim.api.nvim_call_function("reg_recording", {})
						return recordChar ~= ""
					end,
				fmt =
					function()
						local recordChar = vim.api.nvim_call_function("reg_recording", {})
						return "RECORDING @" .. recordChar
					end,
				icon = "⏺",
				color = { fg = "#ff9e64", bg = "#c0392b" },
				padding = {left = 1, right = 1},
				separator = {left = ''},
			},
		},
		lualine_y = {
			{'filetype',
				icons_enabled = false,
				separator = '/',
			},
			{'encoding',
				separator = '/',
			},
			{'fileformat',
				separator = '/',
			},
		},
		lualine_z = {
			{'progress',
				separator = '/',
			},
			'location',
		}
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
			{'filetype',
				padding = { left = 7, right = 1 },
				icon_only = true,
				separator = '', -- Join with next section
			},
			{'filename',
				padding = 0,
				path = 1, -- 0 = Basename, 1 = Relative path, 2 = Absolute path
				symbols = {
					modified = ' [+]',
					readonly = ' [-]',
					unnamed = '[No Name]',
				}
			},
		},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	extensions = {}
})
EOF
endfunction
" }}}
" Plugin: (BUGGY) Kirby - file picker {{{
" Disabled 2023-02-15 but has potencial
Plug 'romgrk/kirby.nvim'
" Dependencies:
Plug 'romgrk/fzy-lua-native', {'do': 'make'}
Plug 'romgrk/kui.nvim'
" }}}
" Plugin: Mini.Animate {{{
Plug 'echasnovski/mini.animate', {'done': 'call s:ConfigMiniAnimate()'}

function s:ConfigMiniAnimate()
lua <<EOF
require('mini.animate').setup({
	cursor = { -- Cursor path
		enable = true,
	},
	scroll = { -- Vertical scroll
		enable = true,
	},
	resize = { -- Window resize
		-- Whether to enable this animation
		enable = true,
	},
	open = { -- Window open
		-- Whether to enable this animation
		enable = true,
	},
	close = { -- Window close
		enable = true,
	},
})
EOF
endfunction
" }}}
" Plugin: Mini.IndentScope {{{
Plug 'echasnovski/mini.indentscope', {'done': 'call s:ConfigMiniIndentScope()'}
" Select entire indent area with `vii` + with outer as `voi`

function s:ConfigMiniIndentScope()
lua <<EOF
require('mini.indentscope').setup({
{
	draw = {
		-- Delay (in ms) between event and start of drawing scope indicator
		delay = 300,
	},

	-- Module mappings. Use `''` (empty string) to disable one.
	mappings = {
		-- Textobjects
		object_scope = 'ii',
		object_scope_with_border = 'oi',

		-- Motions (jump to respective border line; if not present - body line)
		goto_top = '[i',
		goto_bottom = ']i',
	},

	-- Options which control scope computation
	options = {
		-- Type of scope's border: which line(s) with smaller indent to
		-- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'.
		border = 'both',

		-- Whether to use cursor column when computing reference indent.
		-- Useful to see incremental scopes with horizontal cursor movements.
		indent_at_cursor = true,

		-- Whether to first check input line to be a border of adjacent scope.
		-- Use it if you want to place cursor on function header to get scope of
		-- its body.
		try_as_border = false,
	},

	-- Which character to use for drawing scope indicator
	symbol = '╎',
}
})
EOF
endfunction
" }}}
" Plugin: Noice - Cmdline popup + notifications {{{
Plug 'folke/noice.nvim', {'done': 'call s:ConfigNoice()'}

" Dependencies
Plug 'MunifTanjim/nui.nvim'
Plug 'rcarriga/nvim-notify'

function s:ConfigNoice()
	" F2 to dismiss messages
	map <F2> :lua require('notify').dismiss()<CR>

	" Ctrl+F2 to show message history
	map <C-F2> :Noice history<CR>

lua <<EOF
	require('notify').setup({
		background_colour = "#000000",
		render = "compact",
		stages = "slide",
	})

	require('noice').setup({
	})
EOF

endfunction
" }}}
" Plugin: OldFiles - Use :Ol[d] to show a list of previously edited files {{{
Plug 'gpanders/vim-oldfiles', {'done': 'call s:ConfigOldFiles()'}

function s:ConfigOldFiles()
	" Queue up a call to s:ConfigOldFilesBuffer when the quickfix window opens
	autocmd FileType qf if get(w:, 'quickfix_title') == ':Oldfiles' | call timer_start(100, function('s:ConfigOldFilesBuffer')) | endif
endfunction

" Autoclose quickfix window on select
" NOTE: This function fires after 100ms
" Wildfire tries to take over the Quickfix window so we need to patch the
" remap AFTER its done mangling the keymap
function s:ConfigOldFilesBuffer(timerId)
	nnoremap <buffer> <CR> <CR>:cclose<CR>
endfunction
" }}}
" Plugin: OpenInGH - Open a NPM repo in GitHub with `gn` {{{
Plug 'almo7aya/openingh.nvim', {'done': 'call s:ConfigOpenInGH()'}

function s:ConfigOpenInGH()
	nmap gn :OpenInGHRepo<CR>
endfunction
" }}}
" Plugin: OpenRazer - Fancy keyboard functionality if present {{{
Plug 'hash-bang/vim-open-razer'

" STFU if an OpenRazer device is not found
let g:razer_silent = 1

let g:razer_theme = 'mc'
" }}}
" Plugin: Package-info - Display meta information for package.json files {{{
Plug 'vuki656/package-info.nvim', {'done': 'call s:ConfigPackageInfo()'}

function s:ConfigPackageInfo()
lua <<EOF
require('package-info').setup {
	colors = {
		up_to_date = "#3C4048", -- Text color for up to date package virtual text
		outdated = "#D08770", -- Text color for outdated package virtual text
	},

	icons = {
		enable = true,
		style = {
			up_to_date = "  ", -- Icon for up to date packages
			outdated = "  ", -- Icon for outdated packages
		},
	},

	-- Whether to autostart when `package.json` is opened
	autostart = true,

	 -- Hide up to date versions when displaying virtual text
	hide_up_to_date = false,

	-- Hides unstable versions from the version list e.g next-11.1.3-canary3
	hide_unstable_versions = false,

	package_manager = "npm",
}
EOF
endfunction
" }}}
" Plugin: Peekaboo - Display sidebar of buffers when pasting or recording {{{
Plug 'junegunn/vim-peekaboo'
" Press " / @ to access preview of registers
" Use space to toggle fullscreen
" e.g. to paste from register 2 - "2p
" }}}
" Plugin: Pretty-fold - Nicer folds with stats + previews (`h` key) {{{
Plug 'anuvyklack/pretty-fold.nvim', {'done': 'call s:ConfigPrettyFold()'}
Plug 'anuvyklack/fold-preview.nvim'
Plug 'anuvyklack/nvim-keymap-amend' " Needed for preview

function s:ConfigPrettyFold()
lua <<EOF
	require('pretty-fold').setup({
		default_keybindings = false, -- See custom mappings below
		keep_indentation = true,
		remove_fold_markers = true,
		process_comment_signs = 'delete',
		fill_char = '·',
		sections = {
			left = {
				'  ', 'content'
			},
			right = {
				' ', 'number_of_folded_lines', ' / ', 'percentage', ' ',
			}
		}
	})

	require('fold-preview').setup()
EOF
endfunction
" }}}
" Plugin: ProjectConfig - per project .git/project_conf.vim file {{{
Plug 'hiberabyss/ProjectConfig'
" Use :ProjectConfig to edit base file per project
" e.g. `call Heathen2s()`
" }}}
" Plugin: Rename - :rename <file> support {{{
Plug 'danro/rename.vim'
" }}}
" Plugin: Rooter - Set project root directory from known files {{{
Plug 'airblade/vim-rooter'

" Be Quiet on startup
let g:rooter_silent_chdir = 1
" }}}
" Plugin: Startify - Nicer default startup screen {{{
Plug 'mhinz/vim-startify'

" Disable stupid header
let g:startify_custom_header = ''

" Increase number of files
let g:startify_files_number = 20

" Skip certain patterns
let g:startify_skiplist = [
	\ '^/tmp',
	\ '^/home/mc/Dropbox',
	\ '^/home/mc/Papers/Notes/Humour',
	\ '.git/'
\ ]
" }}}
" Plugin: Strip-trailing-whitespace - Remove whitespace on save {{{
Plug 'axelf4/vim-strip-trailing-whitespace'
" }}}
" Plugin: Suda - Sudo read / write access {{{
Plug 'lambdalisue/suda.vim'
" }}}
" Plugin: Super-retab - Fix indenting via :Space2Tab / :Tab2Space {{{
Plug 'rhlobo/vim-super-retab'
" }}}
" Plugin: Surround - Surrounding movement support {{{
Plug 'tpope/vim-surround'
" }}}
" Plugin: Syntastic - ESLint support {{{
" Plug 'vim-syntastic/syntastic', {'done': 'call s:ConfigSyntastic()'}
" Plug 'mtscout6/syntastic-local-eslint.vim'
" ^^^ Trying the below ESLintArgs override - MC 2023-03-07

function s:ConfigSyntastic()
	" FROM https://zirho.github.io/2016/10/06/vim-syntastic-local/
	set statusline+=%#warningmsg#
	set statusline+=%{SyntasticStatuslineFlag()}
	set statusline+=%*

	let g:syntastic_always_populate_loc_list = 1
	let g:syntastic_loc_list_height = 5
	let g:syntastic_auto_loc_list = 1
	let g:syntastic_check_on_open = 1
	let g:syntastic_check_on_wq = 1
	let g:syntastic_javascript_checkers = ['eslint']
	let g:syntastic_loc_list_height = 3

	let g:syntastic_enable_signs = 1
	let g:syntastic_error_symbol = '❌'
	let g:syntastic_style_error_symbol = '⁉️'
	let g:syntastic_warning_symbol = '⚠️'
	let g:syntastic_style_warning_symbol = '💩'

	highlight link SyntasticErrorSign SignColumn
	highlight link SyntasticWarningSign SignColumn
	highlight link SyntasticStyleErrorSign SignColumn
	highlight link SyntasticStyleWarningSign SignColumn

	map gx :SyntasticToggleMode<CR>
	map l] :lnext<CR>
	map l[ :lprevious<CR>

	function! ESLintArgs()
		let rules = findfile('package.json', '.;')
		return rules != '' ? '--rulesdir ' . shellescape(fnamemodify(rules, ':p:h')) : shellescape(fnamemodify('~', ':p:h'))
	endfunction

	autocmd FileType javascript let b:syntastic_javascript_eslint_args = ESLintArgs()
endfunction

" }}}
" Plugin: Tagalong {{{
Plug 'AndrewRadev/tagalong.vim'
let g:tagalong_filetypes = ['doop', 'html', 'vue']
" }}}
" Plugin: Table-Mode - Markdown table editing {{{
Plug 'dhruvasagar/vim-table-mode'
" Move using Cells left / right / above below: [| ]| {| }|

" Setup style like Markdown
let g:table_mode_delimiter = '|'
let g:table_mode_separator = '|'
let g:table_mode_corner_corner = '|'
let g:table_mode_header_fillchar =  '-'
let g:table_mode_corner_corner = '|'

" Map gtt to toggle table mode
noremap gtt <ESC>:set conceallevel=0<CR>:TableModeToggle<CR>
" Map ,tt to create a horizontal header line when any text line is highlighted
nmap ,tt yypV:s/[^\|]/-/<CR>:nohlsearch<CR>
" }}}
" Plugin: Telescope + Plenary {{{
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', {'branch': '0.1.x', 'done': 'call s:ConfigTelescope()'}

" <C-e> to open the old-files list + search
nmap <C-e> :Telescope oldfiles<CR>
" <C-d> to open within current directory
nmap <C-d> :Telescope find_files<CR>

function s:ConfigTelescope()
lua <<EOF
require('telescope').setup({
})
EOF
endfunction
" }}}
" Plugin: Treesitter (et al.) - Syntax, Indent marking, text navigation {{{
" Use :TSInstallInfo for a list of languages
" Use :TSInstall <lang> to update a language
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'done': 'call s:ConfigTreeSitter()'}
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'kiyoon/treesitter-indent-object.nvim'

function s:ConfigTreeSitter()
lua <<EOF
require('nvim-treesitter.configs').setup {
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = {"vue"}, -- Seems to really screw up with Vue files
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
	},
	indent = {
		enable = false,
	},
	textobjects = {
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["]f"] = "@function.outer",
			},
			goto_next_end = {
				["]F"] = "@function.outer",
			},
			goto_previous_star = {
				["[f"] = "@function.outer",
			},
			goto_previous_end = {
				["[F"] = "@function.outer",
			},
		},
	},
}

require("indent_blankline").setup {
	show_current_context = true,
	show_current_context_start = true,
}

require("treesitter_indent_object").setup()

-- select context-aware indent
vim.keymap.set("x", "ai", "<Cmd>lua require'treesitter_indent_object.textobj'.select_indent_outer()<CR>")
-- ensure selecting entire line (or just use Vai)
vim.keymap.set("x", "aI", "<Cmd>lua require'treesitter_indent_object.textobj'.select_indent_outer(true)<CR>")
-- select inner block (only if block, only else block, etc.)
vim.keymap.set("x", "ii", "<Cmd>lua require'treesitter_indent_object.textobj'.select_indent_inner()<CR>")
-- select entire inner range (including if, else, etc.)
vim.keymap.set("x", "iI", "<Cmd>lua require'treesitter_indent_object.textobj'.select_indent_inner(true)<CR>")

EOF
endfunction
" }}}
" Plugin: TreeSJ - Split / join code with gs/gj {{{
Plug 'wansmer/treesj', {'done': 'call s:ConfigTreeSJ()'}

function s:ConfigTreeSJ()
lua <<EOF
require('treesj').setup({
	use_default_keymaps = false,
	dot_repeat = true, -- Use `dot` for repeat action
})
EOF

nmap gt :TSJToggle <CR>
nmap gs :TSJSplit <CR>
nmap gj :TSJJoin <CR>
endfunction
" }}}
" Plugin: Todo-Comments - Highlight various code comments {{{
Plug 'folke/todo-comments.nvim', {'done': 'call s:ConfigTodoComments()' }

function s:ConfigTodoComments()
lua <<EOF
require("todo-comments").setup {
	keywords = {
		FIX  = { icon = " ", color = "warning", alt = {"FIXME", "@FIXME", "BUG", "EXPERIMENTAL"} },
		TODO = { icon = " ", color = "info" },
		HACK = { icon = " ", color = "warning", alt = { "BUG", "KLUDGE" } },
		WARN = { icon = " ", color = "error", alt = { "WARNING", "WARN", "XXX", "CRIT", "CRITICAL" } },
		NOTE = { icon = " ", color = "hint", alt = { "INFO", "UX" } },
	},
	highlight = {
		keyword = "bg", -- Only highlight word, not surrounding chars
	},
	colors = {
		error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
		warning = { "#ecbe7b" },
		info = { "DiagnosticInfo", "#2563EB" },
		hint = { "DiagnosticHint", "#10B981" },
		default = { "Identifier", "#7C3AED" },
	},
}
EOF
endfunction
" }}}
" Plugin: Ultisnips - Snippet library {{{
Plug 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<s-tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Load only MC's own snippets - single DIR search greatly reduces load time
let g:UltiSnipsSnippetDirectories=[$HOME . "/.vim/mc-snippets"]
" }}}
" Plugin: WakaTime - WakaTime integration {{{
if switch_wakatime == 1
	Plug 'wakatime/vim-wakatime'
	let g:wakatime_PythonBinary = '/usr/bin/python3'

	function! s:WakaTimeAutoExec(timer_id)
		echo 'WakaTimeAuto: ' . localtime()
		:WakaTimePulse
	endfunction

	function! WakaTimeAutoOn()
		let s:WakaTimeAutoTimer = timer_start(1000 * 30, function('s:WakaTimeAutoExec'), {'repeat': -1})
		echo "WakaTimeAuto started"
	endfunction
	:command -nargs=0 WakaTimeAutoOn call WakaTimeAutoOn()

	function! WakaTimeAutoOff()
		call timer_stop(s:WakaTimeAutoTimer)
		echo "WakaTimeAuto stopped"
	endfunction
	:command -nargs=0 WakaTimeAutoOff call WakaTimeAutoOff()
endif
" }}}
" Plugin: Wildfire - Inner-to-outer text block selection with <enter> {{{
Plug 'gcmt/wildfire.vim'

" Enter - select the next closest text object.
map <CR> <Plug>(wildfire-fuel)

" Backspace - select the previous text object
map <BS> <Plug>(wildfire-water)

let g:wildfire_objects = {
	\ "*" : ["i'", 'i"', "i)", "i]", "i}", "i`"],
	\ "javascript" : ["i'", 'i"', "i`","i)", "i]", "i}"],
	\ "html,xml" : ["i'", 'i"', "at", "it", "i]", "i}", "i>"],
	\ "vue" : ["i'", 'i"', "i`", "i)", "at", "it", "i]", "i}", "i>"],
\ }
" }}}
" Plugin: WinShift - Move windows interactively (Ctrl+W+M) {{{
Plug 'sindrets/winshift.nvim', {'done': 'call s:ConfigWinShift()' }

" Start Win-Move mode:
nnoremap <C-W><C-M> <Cmd>WinShift<CR>
nnoremap <C-W>m <Cmd>WinShift<CR>

function s:ConfigWinShift()
lua <<EOF
require("winshift").setup({
	highlight_moving_win = true,  -- Highlight the window being moved
	focused_hl_group = "Visual",  -- The highlight group used for the moving window
	moving_win_options = {
		-- These are local options applied to the moving window while it's
		-- being moved. They are unset when you leave Win-Move mode.
		wrap = false,
		cursorline = false,
		cursorcolumn = false,
		colorcolumn = "",
	},
})
EOF
endfunction
" }}}
" Plugin: Which-Key - Replace the spelling prompt with a nicer UI {{{
Plug 'folke/which-key.nvim', {'done': 'call s:ConfigWhichKey()'}

function s:ConfigWhichKey()
lua <<EOF
	require("which-key").setup({
		plugins = {
			spelling = {
				enabled = true,
				suggestions = 20,
			},
		},
	})
EOF

	" Fix which-key screwing with `cc` for some reason
	map cc ^C
endfunction
" }}}
" Plugin: Yanky (Yankring functionality) {{{
Plug 'gbprod/yanky.nvim', {'done': 'call s:ConfigYanky()'}

function s:ConfigYanky()
lua <<EOF
require('yanky').setup({
	ring = {
		history_length = 100,
		storage = "shada",
		sync_with_numbered_registers = true,
		cancel_event = "update",
	},
	picker = {
		select = {
			action = nil, -- nil to use default put action
		},
		telescope = {
			mappings = nil, -- nil to use default mappings
		},
	},
	system_clipboard = {
		sync_with_ring = true,
	},
	highlight = {
		on_put = true,
		on_yank = true,
		timer = 500,
	},
	preserve_cursor_position = {
		enabled = true,
	},
})

-- Basic mapping over paste keys
vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")

-- Ring movement
vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleForward)")
vim.keymap.set("n", "<c-s-p>", "<Plug>(YankyCycleBackward)")

-- Overwrite more complex paste functionality
vim.keymap.set("n", "]p", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[p", "<Plug>(YankyPutIndentBeforeLinewise)")
vim.keymap.set("n", "]P", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[P", "<Plug>(YankyPutIndentBeforeLinewise)")

vim.keymap.set("n", ">p", "<Plug>(YankyPutIndentAfterShiftRight)")
vim.keymap.set("n", "<p", "<Plug>(YankyPutIndentAfterShiftLeft)")
vim.keymap.set("n", ">P", "<Plug>(YankyPutIndentBeforeShiftRight)")
vim.keymap.set("n", "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)")
EOF
endfunction
" }}}
" Plugins: END {{{
call plug#end()
" }}}
" Plugins: Post config (run all `done` handlers){{{
for spec in filter(values(g:plugs), 'has_key(v:val, ''done'')')
	exec spec.done
endfor
" }}}


" Color scheme {{{
se bg=dark
execute 'colors ' . switch_colorscheme

" Override the color or conceals
function RepairColors()
	if g:switch_colorscheme_patch_lightline == 1
		hi Normal ctermfg=223 ctermbg=236
		hi Folded ctermfg=223 ctermbg=238 guifg=Cyan guibg=DarkGrey
		hi LineNr ctermfg=233 ctermbg=239 guifg=Yellow
		hi CursorLineNr ctermfg=233 ctermbg=244 gui=bold guifg=Yellow
	endif

	if g:switch_colorscheme_patch_cursor == 1
		highlight Cursor ctermfg=0 ctermbg=221 guifg=#020221 guibg=#FFC552
		highlight iCursor ctermfg=0 ctermbg=221 guifg=#020221 guibg=#FFC552
	endif

	if g:switch_colorscheme_patch_conceal == 1
		" Light blue
		"highlight Conceal ctermfg=81 ctermbg=none
		" Mild purple
		" highlight Conceal ctermfg=147 ctermbg=none
		" Mild red
		highlight Conceal guifg=#bf616a ctermfg=131 ctermbg=none

		syntax match jsArrowFunction /function/ skipwhite skipempty conceal cchar=λ
		syntax match jsArrowFunction /null/ skipwhite skipempty conceal cchar=ø
		syntax match jsArrowFunction /undefined/ skipwhite skipempty conceal cchar=¿
		syntax match jsArrowFunction /this/ skipwhite skipempty conceal cchar=◉
		syntax match jsArrowFunction /return/ skipwhite skipempty conceal cchar=∴
		syntax match jsArrowFunction /()=>/ skipwhite skipempty conceal cchar=🞅
		syntax match jsArrowFunction /=>/ skipwhite skipempty conceal cchar=🡆
	endif

	if g:switch_colorscheme_patch_visual == 1
		" Override the visual select / searching since most themes royaly screw this up to something discusting like lime-green-on-white
		highlight Visual guifg=#f0e68c guibg=#6b8e23 guisp=#6b8e23 gui=none ctermfg=232 ctermbg=67 cterm=none
		highlight Search guifg=#f0e68c guibg=#6b8e23 guisp=#6b8e23 gui=none ctermfg=232 ctermbg=67 cterm=none

		" Override the visual highlight theme since most themes also screw this up
		highlight Search guifg=#f5deb3 guibg=#cd853f guisp=#cd853f gui=none ctermfg=7 ctermbg=4 cterm=none
	endif

	if g:switch_colorscheme_patch_contrast_folds == 1
		highlight Folded guifg=#f0e68c guibg=#434c5e guisp=#6b8e23 gui=none ctermfg=232 ctermbg=67 cterm=none
	endif

	" Patch Hop colors
	highlight HopNextKey ctermfg=242 ctermbg=0 gui=bold guifg=#D8DEE9 guibg=#5E81AC
	highlight HopNextKey1 ctermfg=242 ctermbg=0 gui=bold guifg=#D8DEE9 guibg=#5E81AC
	highlight HopNextKey2 ctermfg=242 ctermbg=0 gui=bold guifg=#D8DEE9 guibg=#5E81AC
endfunction
call RepairColors()
" }}}

" FIX: Treesitter weird indents for JavaScript + JSDoc {{{
" Taken from https://github.com/nvim-treesitter/nvim-treesitter/issues/1167#issuecomment-920824125
lua <<EOF
function _G.javascript_indent()
	local line = vim.fn.getline(vim.v.lnum)
	local prev_line = vim.fn.getline(vim.v.lnum - 1)
	if line:match('^%s*[%*/]%s*') then
		if prev_line:match('^%s*%*%s*') then
			return vim.fn.indent(vim.v.lnum - 1)
		end
		if prev_line:match('^%s*/%*%*%s*$') then
			return vim.fn.indent(vim.v.lnum - 1) + 1
		end
	end

	return vim.fn['GetJavascriptIndent']()
end

vim.cmd[[autocmd FileType javascript setlocal indentexpr=v:lua.javascript_indent()]]
EOF
" }}}
