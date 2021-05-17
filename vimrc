" MC's overly complex VIM / NeoVIM config file
" God help you if you're using this
"
" @author Matt Carter <m@ttcarter.com>
" @url https://github.com/hash-bang/vimrc

" Shorthand global config switches
let g:switch_wakatime=1 " Enable wakatime Plugin

" Color scheme options
let g:switch_colorscheme = 'tender' " Selected color scheme, must match an entry within `Plugins: COLOR SCHEMES`
let g:switch_colorscheme_patch_conceal = 0 " Repair conceal coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_lightline = 0 " Repair lightline coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_visual = 0 " Repair visua coloring (set automatically by colorscheme preference)


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

" Work where indenting = tab
function HeathenTab()
	set smarttab
	set shiftwidth=8
	set softtabstop=0
	IndentGuidesEnable
	echo "Heathen (Tab) mode"
endfunction

" Work where indenting = 2 spaces
function Heathen2s()
	set smarttab
	set shiftwidth=2
	set softtabstop=2
	let g:indent_guides_guide_size = 2
	IndentGuidesEnable
	echo "Heathen (2 space) mode"
endfunction

" Work where indenting = 4 spaces
function Heathen4s()
	set smarttab
	set shiftwidth=4
	set softtabstop=4
	let g:indent_guides_guide_size = 4
	IndentGuidesEnable
	echo "Heathen (4 space) mode"
endfunction

function! RootW()
	w !sudo tee %
endfunction
command -nargs=* Rootw call RootW()

function! Reformat()
	:%s/\([a-zA-Z0-9,;\'\-]\)\n/\1 /g
	:%s/^ \+//g
endfunction
command -nargs=* Reformat call Reformat()

function White()
	colorscheme morning
endfunction
command -nargs=* White call White()

function Black()
	colorscheme darkbone
endfunction
command -nargs=* Black call Black()

function Book()
	se nonu
	se lbr
	se display=lastline
	se nohls
endfunction

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

function! RmDoubleEmptyLines()
	:%s/\n\n/\r/g
endfunction
command -nargs=* RmDoubleEmptyLines call RmDoubleEmptyLines()

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

command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
	echo a:cmdline
	let expanded_cmdline = a:cmdline
	for part in split(a:cmdline, ' ')
		if part[0] =~ '\v[%#<]'
			let expanded_part = fnameescape(expand(part))
			let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
		endif
	endfor
	botright new
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
	call setline(1, 'You entered:    ' . a:cmdline)
	call setline(2, 'Expanded Form:  ' .expanded_cmdline)
	call setline(3,substitute(getline(2),'.','=','g'))
	execute '$read !'. expanded_cmdline
	setlocal nomodifiable
	1
endfunction
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
" Auto-indent
set ai
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
set lz
" Ignore Python compiled files and backup files
set wig=*.pyc,*.pyo,*.*~
" Force all swap files into the tmp directory
set dir=/tmp
" Enable mode lines (# vim:ft=blah for example)
se modeline
" Make file name completion work just like bash
se wildmenu
se wildmode=longest,list
" Make Shift tab complete file names in insert mode
inoremap <S-Tab> <C-X><C-F>
" Disable backup files before overwrite (i.e. something.txt~ files)
se nowb
" Enable cursor line highlighting
se cursorline
" Keep at least 5 lines above/below
se scrolloff=5
" Keep at least 5 lines left/right
se sidescrolloff=5
" Enable undo files
se undofile
se undodir=$HOME/.vim/undo
" Auto save
se autowrite
" Split vertical windows to the right
se splitright
" Dont wrap searching
se nows
" Set minimal window size to 0 (when using Ctrl+W+_ this minimizes all windows to one line)
se wmh=0
" }}}
" File browser (netrw) Options {{{
" Set default layout to long mode (name, size, date)
let g:netrw_liststyle=1
" }}}
" Themes {{{
" Set 256 Colors (for consoles that can handle it)
set t_Co=256 

" Desert colors
"colorscheme desert256

" ZenBurn (Colors)
let g:zenburn_high_Contrast=1
let g:zenburn_old_Visual=1
let g:zenburn_alternate_Visual=1
" }}}
" File Types {{{ 
autocmd BufRead,BufNewFile *.PAS set ft=pascal
autocmd BufRead,BufNewFile *.pas set ft=pascal
autocmd BufRead,BufNewFile *.ng set ft=vue
autocmd BufRead *.txt set ft=

let g:git_diff_spawn_mode = 1
au! BufRead,BufNewFile COMMIT_EDITMSG call GitSplit()

" Smart indending for Python
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufRead .xfile set ft=xfile

" Remove all whitespace in certain files
autocmd BufWritePre *.css %s/\s\+$//e
autocmd BufWritePre *.js %s/\s\+$//e
autocmd BufWritePre *.json %s/\s\+$//e
autocmd BufWritePre *.html %s/\s\+$//e
" }}}
" Folding {{{
" Use {{{ and }}} to denote a fold in a document
set foldmethod=marker
set commentstring=//\ %s
" }}}
" Abbreviation Map {{{
" alias :W => :w
cabbr W w
" alias :qwa => :wqa
cabbr qwa wqa
" alias :Wqa => :wqa
cabbr Wqa wqa
" alias :Q => :q
cabbr Q q
" command alias f -> function. Useful when locating function names as you can just type 'f ' followed by the name
ca f function
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
" File types (gt*) {{{
map gtb :se ft=sh<CR>
map gtc :se ft=css<CR>
map gth :se ft=html<CR>
map gtj :se ft=javascript<CR>
map gts :se ft=sql<CR>:se nowrap<CR>
map gto :se ft=json<CR>
map gtv :se ft=vue<CR>
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
" Searching {{{
" ,n - search from top
map ,n ggn
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
	map <c-t> :split<CR>:term<CR>
	map <c-w>t :split<CR>:term<CR>

	map <c-y> :vsplit<CR>:term<CR>
	map <c-w>y :vsplit<CR>:term<CR>

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
" F2 - Retab 2 spaces -> tab
map <F2> :set ts=2<CR>:Space2Tab<CR>:set ts=8<CR>
" Shift-F2 - Retab 4 spaces -> tab
map <S-F2> :set ts=4<CR>:Space2Tab<CR>:set ts=8<CR>
" Ctrl + F2 - Work in 2-space indent mode
map <C-F2> :call Heathen2s()
" F3 - Replace active RegExp with nothing
map <F3> :%s///<CR>
" F5 - Reload the current file
map <F5> :e! %<CR>
" F6 - Toggle Spelling
map <F6> :se spell!<CR>
" F7 - Set JavaScript mode
map <F7> :se ft=javascript<CR>
" F8 to give a char count for a selected visual block
map <F8> :echoe "Str Length:" . strlen(GetVisual())<CR>gv
" F10 - HTML Beautifier
map <F10> :w<CR>:%!hindent -c -i8<CR>:%s/\r//g<CR>gg
" Alt-F10 - Stip C-like comments and remove blank lines
map <A-F10> :%s/\(\/\*\(.\\|\n\)*\*\/\\|\/\/.*\n\)//g<CR>:g/^$/:d
" F12 - Disable hilighting
map <F12> :nohlsearch <CR>
imap <F12> <ESC>:nohlsearch <CR>
" XX to save (but not quit like ZZ)
map XX :w <CR>
" QQ to just quit
map QQ :qa <CR>
" MM to go next (cant use 'nn' as it slows down searching)
map mm :n <CR>
" GL - Toggle line numbers
map gl :set number! <CR>
" {{ | }} - Move around functions
map }} ]}
map {{ [{
" Ctrl + P will paste + auto indent
map <C-P> p==

" Bind filetype shortcuts
map gth :set filetype=html<CR>
map gtj :set filetype=javascript<CR>
map gtc :set filetype=css<CR>

" Enable Heathen-Tab mode
map ght :call HeathenTab()<CR>
" Enable Heathen-2S mode
map gh2 :call Heathen2s()<CR>
" Enable Heathen-4S mode
map gh4 :call Heathen4s()<CR>

function! NumberToggle()
	if(&relativenumber == 1)
		set number
	else
		set relativenumber
	endif
endfunc
" nnoremap <C-@> :call NumberToggle()<cr>


" map Z- to toggle spelling
map z- :se spell!<CR>



" Proper casing using the '!' key (not counting words beginning with '.' - so .mp3 is not capitalised to .Mp3)
vmap ! :s/\([^\.]\)\<\([a-z]\)\([a-z]*\)/\1\U\2\E\3/gi <CR>

" Ctrl - A - Increment all Visual area numbers per-line (zero padded)
vnoremap <c-a> :Inc<CR>
" Ctrl - S - Increment all Visual area numbers per-line (no padding)
vnoremap <c-s> :IncN<CR>

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
map ,[ gg
map ,] G

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
" This entire section is pretty much a multiplexor based on switch_colorscheme
if switch_colorscheme == 'cosmic_latte'
	Plug 'nightsense/cosmic_latte'
elseif switch_colorscheme == 'gruvbox'
	Plug 'morhetz/gruvbox'
elseif switch_colorscheme == 'everforest'
	Plug 'sainnhe/everforest'
elseif switch_colorscheme == 'nord'
	Plug 'shaunsingh/nord.nvim'
elseif switch_colorscheme == 'tender'
	Plug 'jacoborus/tender.vim'
elseif switch_colorscheme == 'tokyonight'
	Plug 'folke/tokyonight.nvim'
endif
" }}}
" Plugins: GENERAL SYNTAX {{{
Plug 'LeonB/vim-nginx'
Plug 'hash-bang/vim-vue'
Plug 'hash-bang/vim-todo'
" }}}
" Plugin: SYNTAX / vim-markdown {{{
Plug 'plasticboy/vim-markdown'
" Disable section folding
let g:vim_markdown_folding_disabled = 1

" Disable concealing
let g:vim_markdown_conceal = 0
" }}}

" Plugin: Easymotion {{{
Plug 'Lokaltog/vim-easymotion'
" map ` -> EasyMotion Word
map ` ,,w
" }}}
" Plugin: Emmet {{{
" Ctrl+Y , is default binding
Plug 'mattn/emmet-vim'
" }}}
" Plugin: Fugitive {{{
Plug 'tpope/vim-fugitive'
" }}}
" Plugin: FZF {{{
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Map ,g to open FZF file finder
map ,g :Files<cr>

" Map ,r to RipGrep via FZF
map ,r :Rg<cr>
" }}}
" Plugin: Indent Guides {{{
Plug 'nathanaelkane/vim-indent-guides'
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0

" ctermbg is the color to set, lower colors = lighter
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=237 ctermbg=237
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=238 ctermbg=238
" }}}
" Plugin: Javascript {{{
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

let g:javascript_plugin_jsdoc = 0
" }}}
" Plugin: JSON {{{
Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal = 0
" }}}
" Plugin: Lightline {{{
Plug 'itchyny/lightline.vim'

let g:tender_lightline = 1
let g:lightline = {
	\ 'colorscheme': 'Tomorrow_Night',
	\ 'active': {
	\ 	'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ] ]
	\ },
	\ 'inactive': {
	\ 	'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ] ]
	\ },
	\ 'component': {
	\	'filename': '%f'
	\ },
	\ 'separator': { 'left': '', 'right': '' },
	\ 'subseparator': { 'left': '', 'right': '' }
\ }

" Only usable if using the a lightline compatible font
" \ 'separator': { 'left': "", 'right': "" },
" \ 'subseparator': { 'left': '', 'right': '' },

" Always show the status line
set laststatus=2

" Hide the very bottom footer that VI native uses
set noshowmode
" }}}
" Plugin: MatchTagAlways {{{
Plug 'Valloric/MatchTagAlways'
let g:mta_filetypes = {
    \ 'ejs' : 1,
    \ 'html' : 1,
    \ 'php' : 1,
    \ 'xhtml' : 1,
    \ 'xml' : 1,
    \ 'jinja' : 1,
    \}
" }}}
" Plugin: Nerdtree {{{
Plug 'preservim/nerdtree'
" Map ,` to toggle Nerd tree
map ,` :NERDTreeToggle<cr>
" }}}
" Plugin: SplitJoin {{{
Plug 'git@github.com:AndrewRadev/splitjoin.vim.git'
" }}}
" Plugin: Startify {{{
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
" Plugin: Strip-trailing-whitespace {{{
Plug 'axelf4/vim-strip-trailing-whitespace'
" }}}
" Plugin: Super-retab {{{
Plug 'rhlobo/vim-super-retab'
" }}}
" Plugin: Surround {{{
Plug 'tpope/vim-surround'
" }}}
" Plugin: Tagalong {{{
Plug 'AndrewRadev/tagalong.vim'
let g:tagalong_filetypes = ['doop', 'html', 'vue']
" }}}
" Plugin: Table-Mode {{{
Plug 'dhruvasagar/vim-table-mode'
" " Move using Cells left / right / above below: [| ]| {| }|

" Setup style like Markdown
let g:table_mode_delimiter = '|'
let g:table_mode_separator = '|'
let g:table_mode_corner_corner = '|'
let g:table_mode_header_fillchar =  '-'
let g:table_mode_corner_corner = '|'

" Map gtt to toggle table mode
map gtt :TableModeToggle<CR>
" Map ,tt to create a horizontal header line when any text line is highlighted
map ,tt yypV:s/[^\|]/-/<CR>:nohlsearch<CR>
" }}}
" Plugin: Ultisnips {{{
Plug 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Load only MC's own snippets - single DIR search greatly reduces load time
let g:UltiSnipsSnippetDirectories=[$HOME."/.vim/mc-snippets"]
" }}}
" Plugin: WakaTime {{{
if switch_wakatime == 1
	Plug 'wakatime/vim-wakatime'
	let g:wakatime_PythonBinary = '/usr/bin/python3'
endif
" }}}
" Plugin: Wildfire {{{
Plug 'gcmt/wildfire.vim'
" Enter - select the next closest text object.
map <ENTER> <Plug>(wildfire-fuel)

" Backspace - select the previous text object
map <BS> <Plug>(wildfire-water)

let g:wildfire_objects = {
    \ "*" : ["i'", 'i"', "i)", "i]", "i}", "i`"],
    \ "javascript" : ["i'", 'i"', "i`","i)", "i]", "i}"],
    \ "html,xml" : ["i'", 'i"', "at", "it", "i]", "i}", "i>"],
    \ "vue" : ["i'", 'i"', "i`", "i)", "at", "it", "i]", "i}", "i>"],
\ }
" }}}
" Plugins: END {{{
call plug#end()
" }}}

" Location specific overrides {{{
if filereadable("/tmp/@location")
	" We support mode changes
	function! s:ModeCheck(id)
		if (mode() =~# '\v(n|no)')
			call system("/home/mc/Scripts/mood normal &")
		elseif (mode() =~# '\v(v|V)')
			call system("/home/mc/Scripts/mood visual &")
		elseif (mode() ==# 'i')
			call system("/home/mc/Scripts/mood insert &")
		elseif (mode() =~# 'R')
			call system("/home/mc/Scripts/mood replace &")
		endif
	endfunction
	call timer_start(100, function('s:ModeCheck'), {'repeat': -1})

	autocmd CmdlineEnter * call system("/home/mc/Scripts/mood command &")
	autocmd CmdlineLeave * call system("/home/mc/Scripts/mood normal &")
	autocmd VimLeave * call system("/home/mc/Scripts/mood normal")
	autocmd FocusLost * call system("/home/mc/Scripts/mood normal &")

endif
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

	if g:switch_colorscheme_patch_conceal == 1
		" Light blue
		"highlight Conceal ctermfg=81 ctermbg=none
		" Mild purple
		" highlight Conceal ctermfg=147 ctermbg=none
		" Mild red
		 highlight Conceal ctermfg=131 ctermbg=none
	endif

	if g:switch_colorscheme_patch_visual == 1
		" Override the visual select / searching since most themes royaly screw this up to something discusting like lime-green-on-white
		hi Visual guifg=#f0e68c guibg=#6b8e23 guisp=#6b8e23 gui=none ctermfg=232 ctermbg=67 cterm=none
		hi Search guifg=#f0e68c guibg=#6b8e23 guisp=#6b8e23 gui=none ctermfg=232 ctermbg=67 cterm=none

		" Override the visual highlight theme since most themes also screw this up
		hi Search guifg=#f5deb3 guibg=#cd853f guisp=#cd853f gui=none ctermfg=7 ctermbg=4 cterm=none
	endif
endfunction
call RepairColors()
" }}}
" Cursorline highlighting {{{
" Hide line number highlighting when not in insert mode
" FIXME: Disabled for now as Nvim@0.5.0 seems to slow down
"autocmd InsertEnter * set cul
"autocmd InsertLeave * set nocul
set nocul

" NOTE: Trying this again 2020-12-18 to see if it works
" - NOPE 2020-12-21, drastically slows down .doop editing
" }}}
" Modes {{{
" optional reset cursor on start:
if &term =~ "xterm\\|rxvt"
  " use an orange cursor in insert mode
  let &t_SI = "\<Esc>]12;orange\x7"
  " use a red cursor otherwise
  let &t_EI = "\<Esc>]12;red\x7"
  silent !echo -ne "\033]12;red\007"
  " reset cursor when vim exits
  autocmd VimLeave * silent !echo -ne "\033]112\007"
  " use \003]12;gray\007 for gnome-terminal and rxvt up to version 9.21
endif
" }}}

" BUGFIX: Disable weird cursor support until xfce4-terminal supports it {{{
set guicursor=
" }}}
