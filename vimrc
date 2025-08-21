" MC's overly complex VIM / NeoVIM config file
" God help you if you're using this
"
" @author Matt Carter <m@ttcarter.com>
" @url https://github.com/hash-bang/vimrc

" Shorthand global config switches
let g:switch_wakatime=0 " Enable wakatime Plugin

" Color scheme options
let g:switch_colorscheme = 'nordern' " Selected color scheme, must match an entry within `Plugins: COLOR SCHEMES`

" ariake           - Purple primary
" bamboo           - High-contrast, dark with strong foreground
" bronzage         - yellow / icy blue based muted text
" brown            - Very amber coloring
" cosmic_latte     - Very muted everything with blue & red highlights
" darkearth        - Very muted Brown tones with an earthy feel
" embark           - Very blue, over-saturated, icy theme
" gruber-darker    - Very high-contrast theme
" gruvbox          - Dark but constrasting bright colors
" gruvbox-material - Gruvbox but more metalic
" hybrid2          - Muted blue coloring as primary with high contrast notes
" everforest       - Nord-lite, subtle color blend
" falcon           - Dark background, with orange notes
" kanagawa         - Bold margins + folds, colorful code
" melange          - High-contrast, colorful
" nightfox         - Dark pale blue folds, muted text
" nord             - Default, go-to theme with blue-ice overtones
" nordern          - Icy color scheme with blue + white emphasis
" posterpole       - Muted colors with grey + blue contrast
" serene           - Dark color scheme with dark-blue background
" tender           - Very muted folds, bright colorful text
" tokyonight       - Primarily purple with neon notes
" zenburn          - High contrast

" Functions {{{
" Utility: GetVisual() {{{
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

" BatteryToggle(isBattery = 'auto', quiet = 0) {{{
let g:battery_mode = 0
let g:battery_mode_file = '/tmp/power-mode'
function! BatteryToggle(state = 'auto', quiet = 0)
	let l:set_state = 1
	" Argument munging {{{
	if a:state == 'auto'
		if filereadable(g:battery_mode_file)
			let l:query = readfile(g:battery_mode_file)
			let l:set_state = l:query[0] =~# 'Roaming'
		else
			" No battery state so assume non-battery-mode
			let l:set_state = 0
		endif
	elseif a:state == 'toggle'
		echom "Current battery mode: " . g:battery_mode
		let l:set_state = g:battery_mode
	elseif a:state == 'off'
		let l:set_state = 0
	elseif a:state == 'on'
		let l:set_state = 1
	else
		echom "DEBUG BATTERY SET:[" . a:state . "]"
		let l:set_state = a:state
	endif
	" }}}

	if l:set_state == 1
		echom "Battery mode enabled"
		let g:battery_mode = 1
		let g:ale_lint_on_enter = 0
		let g:ale_lint_on_insert_leave = 0
		let g:ale_lint_on_text_changed = 0
		let g:ale_lint_on_save = 0
	else
		if !a:quiet
			echom "Battery mode disabled"
		endif
		let g:battery_mode = 0
		let g:ale_lint_on_enter = 1
		let g:ale_lint_on_insert_leave = 1
		let g:ale_lint_on_text_changed = 1
		let g:ale_lint_on_save = 1
	endif

	" Toggle Ale on/off to reset config
	exec "ALEToggle"
	exec "ALEToggle"
endfunction

" map ,ba - Battery mode auto
map <silent> ,ba :call BatteryToggle('auto')<CR>

" map ,bb / ,bt - Battery mode toggle
map <silent> ,bb :call BatteryToggle('toggle')<CR>
map <silent> ,bt :call BatteryToggle('toggle')<CR>

" map ,b1 - Battery mode enable
map <silent> ,b1 :call BatteryToggle('on')<CR>

" map ,b0 - Battery mode disable
map <silent> ,b0 :call BatteryToggle('off')<CR>
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

" Heathen4s() - Work where indenting = 4 spaces {{{
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

" Quiet() + Loud() - Hide highlights, dismiss notifications + disable spelling {{{
function! Quiet()
	lua require('notify').dismiss()
	set nohlsearch
	set nospell
endfunction

function! Loud()
	set hlsearch
endfunction
" }}}

" ResolvePath(path) + EditResolvePath(path) - Correct a path to something nicer {{{
function! ResolvePath(path)
	if matchstr("^\.\/?") " ./PATH - Relative to current file
		let fileDir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
		return substitute(a:path, "^\.\/?", l:cwd . "/" , "")
	elseif matchstr("^[@#]\/?", path) " #/PATH - Rooter relative path
		let projectDir = FindRootDirectory()
		return substitute(a:path, "^[@#]\/?", l:projectDir . "/" , "")
	else " Assume its a regular path
		return a:path
	endif
endfunction

function! EditResolvePath(path)
	exe "e " . ResolvePath(path)
endfunction

command -nargs=* E call Editfile(<q-args>)
" }}}

" Wipeout() - Close all non-visible buffers {{{
" @url https://stackoverflow.com/a/1536094
command -nargs=* Wipeout call Wipeout()
function! Wipeout()
	" list of *all* buffer numbers
	let l:buffers = range(1, bufnr('$'))

	" what tab page are we in?
	let l:currentTab = tabpagenr()
	try
		" go through all tab pages
		let l:tab = 0
		while l:tab < tabpagenr('$')
			let l:tab += 1

			" go through all windows
			let l:win = 0
			while l:win < winnr('$')
				let l:win += 1
				" whatever buffer is in this window in this tab, remove it from
				" l:buffers list
				let l:thisbuf = winbufnr(l:win)
				call remove(l:buffers, index(l:buffers, l:thisbuf))
			endwhile
		endwhile

		" if there are any buffers left, delete them
		if len(l:buffers)
			execute 'bwipeout' join(l:buffers)
		endif
	finally
		" go back to our original tab page
		execute 'tabnext' l:currentTab
	endtry
endfunction
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
" Disable annoying "Hit enter to continue" messages in some circumstances
" Default is `ltToOCFI`
set shortmess=aCFImOt

" Set tab width
set tabstop=4
set shiftwidth=4

" Set the command line height to auto-hide
" NOTE: This behaviour is applied by Noice anyway so is not explicitly needed any more
" set cmdheight=0

" Set timeout for multi-key mappings
" Default: 1000
set timeoutlen=500
" }}}
" File browser (netrw) Options {{{
" Set default layout to long mode (name, size, date)
let g:netrw_liststyle=1
" }}}
" File Types / AutoCmd {{{
autocmd BufRead,BufNewFile *.PAS set ft=pascal
autocmd BufRead,BufNewFile *.pas set ft=pascal
autocmd BufRead,BufNewFile *.ng set ft=vue
autocmd BufRead,BufNewFile *.txt set ft=
autocmd BufRead,BufNewFile NOTES set ft=todo
autocmd BufRead,BufNewFile MEETINGS set ft=todo
autocmd BufRead,BufNewFile MEETINGS set ft=todo
autocmd BufRead,BufNewFile *.TODO set ft=todo
autocmd BufRead,BufNewFile *.doop set ft=javascript
autocmd BufRead,BufNewFile .env* set ft=dotenv

" Smart indending for Python
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufRead .xfile set ft=xfile

" Remove all whitespace in certain files
autocmd BufWritePre *.css %s/\s\+$//e
autocmd BufWritePre *.js %s/\s\+$//e
autocmd BufWritePre *.json %s/\s\+$//e
autocmd BufWritePre *.html %s/\s\+$//e

" Terminals
autocmd TermOpen * setlocal nonu
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

	let fillcharcount = winwidth('%') - len(line_text) - len(folded_line_num) - 13
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
command -nargs=0 Qw :wq
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
imap <m-p> <ESC>"+pa
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

" Switch to fold method by indent
map <silent> gfi :se foldmethod=indent<CR>
" }}}
" File list (really "buffer") naivgaton {{{
" Move to next file with `mm`
nmap <silent> mm :n<CR>
" }}}
" File types (gt*) {{{
nmap gtb :se ft=sh<CR>
nmap gtc :se ft=csv<CR>:CsvViewEnable<CR>
nmap gth :se ft=html<CR>
nmap gtj :se ft=javascript<CR>
nmap gts :se ft=sql<CR>:se nowrap<CR>
nmap gto :se ft=json<CR>
nmap gtv :se ft=vue<CR>
" }}}
" Movement {{{
" Alt+A - move to start of line (same as "^")
nmap <M-a> ^
imap <M-a> <esc>^i

" Alt+Z - move to end of line (same as "$")
nmap <M-z> $
imap <M-z> <esc>$i

" `T` - move to last character within line
noremap T $F
" }}}
" Pasting {{{
" Map `gp` to select last pasted text
" gv / gpp - select previously pasted text (`gp` can't be remapped for some reason)
nnoremap <expr> gpp '`[' . getregtype()[0] . '`]'
" }}}
" Saving {{{
" These commands are wrapped in Lua and use vim.keymap.set to bypass
" the Noice command line popup
lua <<EOF
	-- Silent write with "XX"
	vim.keymap.set({"n", "v"}, "XX", ":wa!<CR>", {silent = true})

	-- Silent write + quit with "ZZ"
	vim.keymap.set({"n", "v"}, "ZZ", ":wqa!<CR>", {silent = true})
EOF
" }}}
" Searching {{{
" ,n - search from top
map ,n ggn
" }}}
" Shell Execution {{{
" <gw> to open word/file under cursor in web browser or default app
function! OpenURL()
	let line = getline('.')
	let col = col('.')

	" Match common URL patterns
	let url_pattern = 'https\?://[[:alnum:]._~:/?#[\]@!$&''()*+,;=%%-]\+'
	let url = matchstr(line, url_pattern, 0)

	" If no http(s), try other patterns
	if empty(url)
		let url = matchstr(line, 'www\.[[:alnum:]._~:/?#[\]@!$&''()*+,;=%%-]\+')
		if !empty(url)
			let url = 'http://' . url
		endif
	endif

	if !empty(url)
		if has('mac')
			call system('open ' . shellescape(url))
		elseif has('unix')
			call system('xdg-open ' . shellescape(url))
		elseif has('win32')
			call system('start ' . shellescape(url))
		endif
	else
		echo "No URL found on this line"
	endif
endfunction
nnoremap gw :call OpenURL()<CR>
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

" Ctrl+A to select all in visual mode
map <C-A> ggVG
nmap <C-A> <esc>ggVG
" }}}
" Windows {{{
" <C-W>S (capital S) opens UNDER current window
map <silent> <c-w>S :split<cr><c-w>j

" <C-W>V (capital V) opens TO RIGHT of current window
map <silent> <c-w>V :vsplit<cr><c-w>h

" <C-W>P Closes all preview windows
map <silent> <c-w>p :pclose<cr>

" <C-W>O close all background buffers, releasing all non-active files
nmap <silent> <c-w>O :Wipeout<cr>
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
map <silent> <F12> :set nohls<CR>
imap <silent> <F12> <ESC>:set nohls<CR>
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
" VimRC management {{{
" <leader>v to reload vimrc + run PlugInstall
nnoremap <silent><leader>v :source ~/.vim/vimrc \| :PlugInstall<CR>
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
let g:switch_colorscheme_patch_background = 0 " Force background to be transparent instead of the default NOTE: This is handled by the transparent plugin for now
let g:switch_colorscheme_patch_cursor = 0 " Repair cursor coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_conceal = 0 " Repair conceal coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_lightline = 0 " Repair lightline coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_visual = 0 " Repair visual coloring (set automatically by colorscheme preference)
let g:switch_colorscheme_patch_contrast_folds = 0 " Repair folds in high-contrast mode
let g:switch_colorscheme_patch_ale_virtualtext = 1 " Repair ALE virtual text coloring
let g:switch_colorscheme_patch_errormsg = 0 " Repair ErrorMsg coloring
let g:switch_colorscheme_patch_todo = 0 " Repair Todo coloring
" }}}

" This entire section is pretty much a multiplexor based on switch_colorscheme

" Plug area (so everything keeps updated)
Plug 'ribru17/bamboo.nvim'
Plug 'habamax/vim-bronzage'
Plug 'bhrown/brown.vim'
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
Plug 'rebelot/kanagawa.nvim'
Plug 'ColinKennedy/hybrid2.nvim'
Plug 'jim-at-jibba/ariake.nvim'
Plug 'ptdewey/darkearth-nvim'
Plug 'blazkowolf/gruber-darker.nvim'
Plug 'sainnhe/gruvbox-material'
Plug 'samharju/serene.nvim'
Plug 'fcancelinha/nordern.nvim'
Plug 'ilof2/posterpole.nvim'

" Overrides based on colorscheme
if switch_colorscheme == 'anotherdark'
	" Another dark is a built in anyway
	let g:switch_colorscheme_patch_lightline = 1
	let g:switch_colorscheme_patch_visual = 1
	colorscheme anotherdark
elseif switch_colorscheme == 'ariake'
	let g:switch_colorscheme_patch_contrast_folds = 1
elseif switch_colorscheme == 'bamboo'
	let g:switch_colorscheme_patch_conceal = 1
elseif switch_colorscheme == 'everforest'
	let g:switch_colorscheme_patch_todo = 1
elseif switch_colorscheme == 'falcon'
	let g:switch_colorscheme_patch_cursor = 1
	let g:switch_colorscheme_patch_todo = 1
elseif switch_colorscheme == 'gruvbox-material'
	let g:switch_colorscheme_patch_todo = 1
elseif switch_colorscheme == 'hybrid2'
	let g:switch_colorscheme_patch_conceal = 1
elseif switch_colorscheme == 'nightfox'
	let g:switch_colorscheme_patch_conceal = 1
elseif switch_colorscheme == 'nord'
	let g:switch_colorscheme_patch_background = 1
	let g:switch_colorscheme_patch_contrast_folds = 1
	let g:switch_colorscheme_patch_conceal = 1
	let g:switch_colorscheme_patch_errormsg = 1
elseif switch_colorscheme == 'tender'
	let g:switch_colorscheme_patch_conceal = 1
	let g:switch_colorscheme_patch_todo = 1
elseif switch_colorscheme == 'zenburn'
	let g:zenburn_high_Contrast=1
	let g:zenburn_old_Visual=1
	let g:zenburn_alternate_Visual=1
	colorscheme zenburn
endif
" }}}
" Plugins: GENERAL SYNTAX {{{
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

" Plugin: Aerial - F1 to toggle file ToC {{{
Plug 'stevearc/aerial.nvim', {'done': 'call s:ConfigAerial()'}
Plug 'onsails/lspkind.nvim'

function s:ConfigAerial()
lua <<EOF
	require('lspkind').init({
	})

	require('aerial').setup({
		default_direction = 'prefer_right',
		show_guides = true,
	})

	vim.keymap.set({'n', 'i', 'v'}, '<F1>', require('aerial').toggle)
EOF
endfunction
" }}}
" Plugin: Actually - correct mis-typed filenames on open {{{
" @url https://github.com/mong8se/actually.nvim
Plug 'mong8se/actually.nvim'
" }}}
" Plugin: AutoCmdHeight - Resize AutoCmd for output messages {{{
Plug 'jake-stewart/auto-cmdheight.nvim', {'done': 'call s:ConfigAutoCmdHeight()'}

function s:ConfigAutoCmdHeight()
lua <<EOF
	require('auto-cmdheight').setup({
		-- max cmdheight before displaying hit enter prompt.
		max_lines = 5,

		-- number of seconds until the cmdheight can restore.
		duration = 2,

		-- whether key press is required to restore cmdheight.
		remove_on_key = true,

		-- always clear the cmdline after duration and key press.
		-- by default it will only happen when cmdheight changed.
		clear_always = false,
	})
EOF
endfunction
" }}}
" Plugin: ALE - Syntax checking via eslint {{{
Plug 'dense-analysis/ale', {'done': 'call s:ConfigALE()'}
" @url https://github.com/dense-analysis/ale
"
" Linter leading key is 'l'
" - Lint NOW: ll
" - Toggle: lt || l-
" - Fix this: l=
" - Clear (show none): lc
" - Ignore this: li
" - First item: lg
" - Next item: ln || l]
" - Previous item: lp || l[

function s:ConfigALE()
	" Linter overrides {{{
	" Only enable eslint for JS
	let g:ale_linters = {'javascript': ['eslint']}

	" Disable for .min.js files
	let g:ale_pattern_options = {'\.min.js$': {'ale_enabled': 0}}
	" }}}

	" Triggering {{{
	" Delay before sending request to LSP for completions after typing
	let g:ale_completion_delay = 200
	let g:ale_lint_on_enter = 1
	let g:ale_lint_on_filetype_changed = 1
	let g:ale_lint_on_save = 1
	let g:ale_lint_on_insert_leave = 1
	" }}}

	" Display {{{
	" Disable Handing off errors to NeoVIM, let ALE handle the display
	let g:ale_use_neovim_diagnostics_api = 0

	" Disable sending echo for current complaint
	let g:ale_echo_cursor = 0

	" Display errors at end of line as virtualtext
	let g:ale_virtualtext_cursor = 'all'
	let g:ale_virtualtext_prefix = ' %severity%% # code% - '
	let g:ale_virtualtext_cursor = 'all' " ENUM: 'all', 'current'

	" LSP list options
	let g:ale_lsp_show_message_format = '%s (%severity%%/code%)'
	let g:ale_lsp_show_message_severity = 'warning' " Min level to show

	" Show ALE complaint in floating preview window
	let g:ale_cursor_detail = 0 " Open when on same line
	let g:ale_hover_to_floating_preview = 1
	let g:ale_detail_to_floating_preview = 1

	" Gutter themes
	" For Ale highlight colors overrides see RepairColors()
	let g:ale_sign_error = ' '
	highlight link ALEErrorSign NotifyERRORIcon

	let g:ale_sign_warning = ' '
	highlight link ALEInfoSign NotifyWARNIcon
	" }}}

	" Key map {{{
	" Lint NOW: ll
	map ll <Plug>(ale_lint)

	" Toggle: lt || l-
	map <silent> lt :ALEToggle<CR>
	map <silent> l- :ALEToggle<CR>
	function! ALEToggle()
		exec "ALEToggle"
		if g:ale_enabled == 1
			echo "ALE linting enabled"
		else
			echo "ALE linting disabled"
		endif
	endfunction

	" Fix: l=
	map l= <Plug>(ale_fix)

	" Clear: lc
	map lc <Plug>(ale_reset)

	" Ignore this: li
	map <silent> li :call ALEIgnore()<CR>
	function! ALEIgnore()
		" https://stackoverflow.com/questions/54961318/vim-ale-shortcut-to-add-eslint-ignore-hint
		let l:codes = []
		if (!exists('b:ale_highlight_items'))
			echo 'Cannot ignore eslint rule without b:ale_highlight_items'
			return
		endif
		for l:item in b:ale_highlight_items
			if (l:item['lnum']==line('.') && l:item['linter_name']=='eslint')
				let l:code = l:item['code']
				call add(l:codes, l:code)
			endif
		endfor
		if len(l:codes)
			exec 'normal O/* eslint-disable-next-line ' . join(l:codes, ', ') . ' */'
		endif
	endfunction

	" First item: lg
	map lg <Plug>(ale_first)

	" Next item: ln || l]
	map ln <Plug>(ale_next_wrap)
	map l] <Plug>(ale_next_wrap)

	" Previous item: lp || lN || l[
	map lp <Plug>(ale_previous_wrap)
	map lN <Plug>(ale_previous_wrap)
	map l[ <Plug>(ale_previous_wrap)
	" }}}
endfunction
" }}}
" Plugin: Blame - Show hide blame with :ToggleBlame or gb {{{
Plug 'FabijanZulj/blame.nvim', {'done': 'call s:ConfigBlame()'}

function s:ConfigBlame()
lua <<EOF
	require('blame').setup({
		virtual_style = 'right_align',
	})

	vim.keymap.set({"n", "v"}, "gb", ":BlameToggle<CR>", {silent = true})
EOF
endfunction
" }}}
" Plugin: Bullets - Auto continue bullets / numered lists {{{
Plug 'bullets-vim/bullets.vim'
" }}}
" Plugin: Comment - Comment line/block toggling {{{
Plug 'numToStr/Comment.nvim', {'done': 'call s:ConfigComment()'}
" @url https://github.com/numToStr/Comment.nvim

function s:ConfigComment()
lua <<EOF
	require('Comment').setup({
		padding = true, -- Add a space b/w comment and the line
		sticky = true, -- Whether the cursor should stay at its position
		mappings = {
			basic = false,
			extra = false,
		},
	})

	-- Map # Toggle comment
	vim.keymap.set('n', '#', '<Plug>(comment_toggle_linewise_current)')

	-- Map # (visual mode) to toggle comment block
	vim.keymap.set('v', '#', '<Plug>(comment_toggle_blockwise_visual)')
EOF
endfunction
" }}}
" Plugin: Conoline - CUL line highlight for current window {{{
Plug 'miyakogi/conoline.vim'

let g:conoline_auto_enable = 1
" }}}
" Plugin: Edit CSV files with `:CsvViewToggle` {{{
Plug 'hat0uma/csvview.nvim', {'done': 'call s:ConfigCSVView()'}
" @url https://github.com/hat0uma/csvview.nvim

function s:ConfigCSVView()
lua <<EOF
	require('csvview').setup({
		parser = {
			--- The number of lines that the asynchronous parser processes per cycle.
			--- This setting is used to prevent monopolization of the main thread when displaying large files.
			--- If the UI freezes, try reducing this value.
			--- @type integer
			async_chunksize = 50,

			--- The delimiter character
			--- You can specify a string, a table of delimiter characters for each file type, or a function that returns a delimiter character.
			--- Currently, only fixed-length strings are supported. Regular expressions such as \s+ are not supported.
			--- e.g:
			---  delimiter = ","
			---  delimiter = function(bufnr) return "," end
			---  delimiter = {
			---    default = ",",
			---    ft = {
			---      tsv = "\t",
			---    },
			---  }
			--- @type CsvView.Options.Parser.Delimiter
			delimiter = {
				default = ",",
				ft = {
					tsv = "\t",
				},
			},

			--- The quote character
			--- If a field is enclosed in this character, it is treated as a single field and the delimiter in it will be ignored.
			--- e.g:
			---  quote_char= "'"
			--- You can also specify it on the command line.
			--- e.g:
			--- :CsvViewEnable quote_char='
			--- @type string
			quote_char = '"',

			--- The comment prefix characters
			--- If the line starts with one of these characters, it is treated as a comment.
			--- Comment lines are not displayed in tabular format.
			--- You can also specify it on the command line.
			--- e.g:
			--- :CsvViewEnable comment=#
			--- @type string[]
			comments = {
				-- "#",
				-- "--",
				-- "//",
			},

			--- Maximum lookahead for multi-line fields
			--- This limits how many lines ahead the parser will look when trying to find
			--- the closing quote of a multi-line field. Setting this too high may cause
			--- performance issues when editing files with unmatched quotes.
			--- @type integer
			max_lookahead = 50,
		},
		view = {
			--- minimum width of a column
			--- @type integer
			min_column_width = 5,

			--- spacing between columns
			--- @type integer
			spacing = 2,

			--- The display method of the delimiter
			--- "highlight" highlights the delimiter
			--- "border" displays the delimiter with `│`
			--- You can also specify it on the command line.
			--- e.g:
			--- :CsvViewEnable display_mode=border
			---@type CsvView.Options.View.DisplayMode
			display_mode = "border",

			--- The line number of the header
			--- If this is set, the line is treated as a header. and used for sticky header feature.
			--- see also: `view.sticky_header`
			--- @type integer|false
			header_lnum = false,

			--- The sticky header feature settings
			--- If `view.header_lnum` is set, the header line is displayed at the top of the window.
			sticky_header = {
				--- Whether to enable the sticky header feature
				--- @type boolean
				enabled = true,

				--- The separator character for the sticky header window
				--- set `false` to disable the separator
				--- @type string|false
				separator = "─",
			},
		},
	})
EOF
endfunction
" }}}
" Plugin: DiffView - Git history views for files via :DiffView* {{{
Plug 'sindrets/diffview.nvim', {'done': 'call s:ConfigDiffView()'}

function s:ConfigDiffView()
lua <<EOF
require('diffview').setup({
})
EOF
endfunction
" }}}
" Plugin: Emmet - Use <C-Y>, to transform CSS under cursor to HTML via Emmet {{{
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
Plug 'lewis6991/gitsigns.nvim', {'done': 'call s:ConfigGitSigns()' }

function s:ConfigGitSigns()
lua <<EOF
	require('gitsigns').setup({
		sign_priority = 6,
		signcolumn = true, -- Show sign column line
		numhl = true, -- Highlight line number in change color
	})
EOF

" map ]h / ]h to jump to next / previous hunk
map ]h :lua require('gitsigns.actions').next_hunk()<CR>
map [h :lua require('gitsigns.actions').prev_hunk()<CR>
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
" Plugin: Incr - Select inner / outer selection areas using TreeSitter + <tab>/ <s-tab> {{{
Plug 'daliusd/incr.nvim', {'done': 'call s:ConfigIncr()'}

function s:ConfigIncr()
lua <<EOF
	require('incr').setup({
		incr_key = '<tab>', -- increment selection key
		decr_key = '<s-tab>', -- decrement selection key
	})
EOF
endfunction
" }}}
" Plugin: Increment - Improve default incrementing functionality with visual selects {{{
Plug 'triglav/vim-visual-increment'

" <C-S> / <M-S> / <M-Z> Increment all Visual area numbers per-line
vnoremap <c-a> :Inc<CR>
vnoremap <m-a> :Inc<CR>

" <C-S> / <M-S> / <M-Z> Decrement all Visual area numbers per-line
vnoremap <c-s> :Dec<CR>
vnoremap <m-s> :Dec<CR>
vnoremap <m-z> :Dec<CR>
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
" Plugin: LSPConfig / TypeScript {{{
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'neovim/nvim-lspconfig', {'done': 'call s:ConfigLSP()'}
Plug 'Jezda1337/nvim-html-css'
Plug 'SergioRibera/cmp-dotenv'

function s:ConfigLSP()
lua <<EOF
	-- LSP setup
	local lspconfig = require('lspconfig')
	local cmp = require('cmp')

	-- Enable lspconfig Packages {{{
	-- This should correspond to the cms.setup() # sources list below

	-- nvim_lsp is a builtin
	-- luasnip is not managed by lspconfig
	-- vim.lsp.enable('vue_ls') -- Throws errors
	vim.lsp.enable('ts_ls')
	vim.lsp.enable('eslint')
	vim.lsp.enable('just')
	-- dotenv is not managed by lspconfig
	-- html-css is not managed by lspconfig
	-- }}}

	-- Key mappings
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {noremap=true, silent=true})
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {noremap=true, silent=true})
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, {noremap=true, silent=true})
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {noremap=true, silent=true})
	vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {noremap=true, silent=true})
	vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {noremap=true, silent=true})
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, {noremap=true, silent=true})
	vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, {noremap=true, silent=true})

	-- Completion setup
	cmp.setup({
		snippet = {
			expand = function(args)
				require('luasnip').lsp_expand(args.body)
			end,
		},
		mapping = cmp.mapping.preset.insert({
			['<C-b>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-e>'] = cmp.mapping.abort(),
			['<Tab>'] = cmp.mapping.confirm({ select = true }),
			['<C-Enter>'] = cmp.mapping.confirm({ select = true }),
			['<C-Space>'] = cmp.mapping.confirm({ select = true }),
		}),
		sources = cmp.config.sources({
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' },
			{ name = 'vue_ls' },
			{ name = 'ts_ls' },
			{ name = 'eslint' },
			{ name = 'just' },
			{ name = 'dotenv' },
			{ name = 'html-css' },
		}),

		-- Window / dropdown style {{{
		-- Based on https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-get-types-on-the-left-and-offset-the-menu
		window = {
			completion = {
				winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
				col_offset = -3,
				side_padding = 0,
			},
		},
		formatting = {
			fields = { "kind", "abbr", "menu" },
			format = function(entry, vim_item)
				local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
				local strings = vim.split(kind.kind, "%s", { trimempty = true })
				kind.kind = " " .. (strings[1] or "") .. " "
				kind.menu = "    (" .. (strings[2] or "") .. ")"

				return kind
			end,
		},
		-- }}}
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
			component_separators = '|',
			section_separators = { left = '', right = '' },
			always_divide_middle = true,
		},
		sections = {
			lualine_a = {
				{'mode',
					padding = {left = 1, right = 1},
				},
			},
			lualine_b = {
				{'branch',
					padding = {left = 1, right = 1},
				},
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
					separator = {left = ''},
				},
			},
			lualine_y = {
				{'filetype',
					icons_enabled = false,
					separator = '|',
				},
				{'encoding',
					separator = '|',
				},
				{'fileformat',
					separator = '|',
				},
			},
			lualine_z = {
				{'progress',
					separator = '|',
					padding = {left = 1, right = 1},
				},
				'location',
				{'g:battery_mode', -- Battery display, shows only if in detected battery mode
					fmt =
						function()
							return '🔽'
						end,
					cond =
						function()
							return vim.g.battery_mode == 1
						end,
				},
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
			lualine_x = {
				{'location',
					padding = {left = 1, right = 0},
				},
			},
			lualine_y = {},
			lualine_z = {}
		},
		tabline = {},
		extensions = {}
	})
EOF
endfunction
" }}}
" Plugin: LuaSnip - Snippet manager {{{
Plug 'L3MON4D3/LuaSnip', {'do': 'make install_jsregexp', 'done': 'call s:ConfigLuaSnip()'}
" @url https://github.com/L3MON4D3/LuaSnip

function s:ConfigLuaSnip()
lua <<EOF
	local ls = require('luasnip')
	ls.setup()

	require('luasnip.loaders.from_snipmate').lazy_load({
		paths = '~/.vim/mc-snippets',
	})

	-- Keymap example taken from https://github.com/L3MON4D3/LuaSnip/issues/978#issue-1840427692
    local function interp(k) vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(k, true, false, true), 'n', false) end

    vim.keymap.set({'i', 's'}, '<C-Tab>', function()
      if ls.expand_or_jumpable() then ls.expand_or_jump()
      else interp('<Tab>') end
    end)

    vim.keymap.set({'i', 's'}, '<S-Tab>', function()
      if ls.jumpable(-1) then ls.jump(-1)
      else interp('<S-Tab>') end
    end)
EOF
endfunction
" }}}
" Plugin: Mini.Animate  - Animation effects {{{
" @url https://github.com/echasnovski/mini.animate
Plug 'echasnovski/mini.animate', {'done': 'call s:ConfigMiniAnimate()'}

function s:ConfigMiniAnimate()
lua <<EOF
	require('mini.animate').setup({
		cursor = { -- Cursor path
			enable = true,
		},
		scroll = { -- Vertical scroll
			enable = false,
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
" (DISABLED) Plugin: Mini.IndentScope {{{
" DISABLED - Slows down UI
Plug 'echasnovski/mini.indentscope' ", {'done': 'call s:ConfigMiniIndentScope()'}

function s:ConfigMiniIndentScope()
lua <<EOF
	require('mini.indentscope').setup({
		draw = {
			-- Delay (in ms) between event and start of drawing scope indicator
			delay = 300,
		},

		-- Module mappings. Use `''` (empty string) to disable one.
		mappings = {
			-- Textobjects
			-- MAP `vii` to select entire indent block
			object_scope = 'ii',
			object_scope_with_border = 'oi',

			-- Motions (jump to respective border line; if not present - body line)
			-- MAP `[i` / `]i` to jump to start / end of indent block
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
	})
EOF
endfunction
" }}}
" Plugin: Oil - Replacement for built-in file explorer {{{
" @url https://github.com/stevearc/oil.nvim
Plug 'stevearc/oil.nvim', {'done': 'call s:ConfigOil()'}
Plug 'refractalize/oil-git-status.nvim'

function s:ConfigOil()
lua <<EOF
	require('oil').setup({
		-- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
		default_file_explorer = true,

		-- Id is automatically added at the beginning, and name at the end
		-- See :help oil-columns
		columns = {
			"icon",
			-- "permissions",
			"size",
			"mtime",
		},
	})

	require('oil-git-status').setup()
EOF
endfunction
" }}}
" Plugin: Noice - Cmdline popup + notifications {{{
Plug 'folke/noice.nvim', {'done': 'call s:ConfigNoice()'}
" @url https://github.com/folke/noice.nvim

" Dependencies
Plug 'MunifTanjim/nui.nvim'
Plug 'rcarriga/nvim-notify'

function s:ConfigNoice()
	" F2 to dismiss messages
	imap <silent> <F2> <esc>:call Quiet()<CR>
	map <silent> <F2> :call Quiet()<CR>

	" (Ctrl|Shift)+F2 to bring back highlighting
	map <silent> <C-F2> :call Load()<CR>
	map <silent> <S-F2> :call Load()<CR>

lua <<EOF
	require('notify').setup({
		background_colour = "#000000",
		render = "compact",
		stages = "slide",
	})

	require('noice').setup({
		routes = {
			{ -- Redirect input prompts (e.g. spelling) to wait for user responses
				filter = {
					kind = 'number_prompt',
				},
				view = 'mini',
			},
		}
	})
EOF

endfunction
" }}}
" (DISABLED) Plugin: OpenRazer - Fancy keyboard functionality if present {{{
" Plug 'hash-bang/vim-open-razer'

" STFU if an OpenRazer device is not found
let g:razer_silent = 1

let g:razer_theme = 'mc'
" }}}
" Plugin: Package-info - Display meta information for package.json files {{{
Plug 'vuki656/package-info.nvim', {'done': 'call s:ConfigPackageInfo()'}

function s:ConfigPackageInfo()
lua <<EOF
	require('package-info').setup({
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
	})
EOF
endfunction
" }}}
" Plugin: Peekaboo - Display sidebar of buffers when pasting or recording {{{
Plug 'junegunn/vim-peekaboo'
" Press " / @ to access preview of registers
" Use space to toggle fullscreen
" e.g. to paste from register 2 - "2p
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
" Plugin: Session-Manager - Read/Write sessions {{{
" @url https://github.com/Shatur/neovim-session-manager
Plug 'Shatur/neovim-session-manager', {'done': 'call s:ConfignSessionManager()'}

function s:ConfignSessionManager()
lua <<EOF
	local config = require('session_manager.config')
	require('session_manager').setup({
		autoload_mode = config.AutoloadMode.Disabled, -- How to handle vim starting without args
	})

	-- Map sl - Load last session
	vim.keymap.set("n", "sl", ":SessionManager load_last_session<CR>:echo 'Saved active session'<CR>", {silent = true})

	-- Map sw - Save current session
	vim.keymap.set("n", "sw", ":SessionManager save_current_session<CR>:echo 'Saved active session'<CR>", {silent = true})

	-- Map sd - Drop current session
	vim.keymap.set("n", "sd", ":SessionManager delete_session<CR>:echo 'Deleted session'<CR>", {silent = true})
EOF

endfunction
" }}}
" Plugin: Silicon - Code shots into .png files {{{
Plug 'michaelrommel/nvim-silicon', {'done': 'call s:ConfigSilicon()'}
" @url https://github.com/michaelrommel/nvim-silicon

function s:ConfigSilicon()
lua <<EOF
	require('nvim-silicon').setup({
		output = function() -- Timestamp code output
			return "~/Burnbag/" .. os.date("!%Y-%m-%dT%H-%M-%S") .. ".png"
		end,
	})

	-- Visual yank to silicon - <leader>sy
	vim.keymap.set('v', '<leader>sy', function() require('nvim-silicon').file() end, {silent = true})
EOF
endfunction
" }}}
" Plugin: Startify - Nicer default startup screen {{{
Plug 'mhinz/vim-startify'

" Disable stupid header
let g:startify_custom_header = ''

" Increase number of files
let g:startify_files_number = 20

" Add global bookmarks
let g:startify_bookmarks = [
	\ '~/Notes/Notes.txt',
	\ '~/.vim/vimrc',
	\ '~/.zshrc'
\ ]

" Skip certain patterns
let g:startify_skiplist = [
	\ '^/tmp',
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
" Plugin: Super-retab - Fix indenting via :Space2Tab / :Tab2Space OR ,2 || ,4 {{{
Plug 'rhlobo/vim-super-retab'

nmap <silent> ,2 <ESC>:Space2Tab 2<CR>
vmap <silent> ,2 :Space2Tab 2<CR>gv
nmap <silent> ,4 <ESC>:Space2Tab 4<CR>
vmap <silent> ,2 :Space2Tab 4<CR>gv
" }}}
" Plugin: Surround - Surrounding movement support {{{
Plug 'tpope/vim-surround'
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
noremap <silent> gtt <ESC>:set conceallevel=0<CR>:TableModeToggle<CR>

" Map gtn to realign tables now
noremap <silent> gtn <ESC>:TableModeRealign<CR>

" Map ,tt to create a horizontal header line when any text line is highlighted
nmap <silent> ,tt yypV:s/[^\|]/-/<CR>:nohlsearch<CR>
" }}}
" Plugin: Telescope + Plenary {{{
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', {'branch': '0.1.x', 'done': 'call s:ConfigTelescope()'}

" <C-e> to open the old-files list + search
nmap <silent> <C-s-e> :Telescope oldfiles<CR>
" <C-d> to open within current directory
nmap <silent> <C-d> :Telescope find_files<CR>

function s:ConfigTelescope()
lua <<EOF
	require('telescope').setup({
	})
EOF
endfunction
" }}}
" Plugin: Telescope + Smart Open - Guess the file to edit via Telescope (Ctrl+E) {{{
Plug 'danielfalk/smart-open.nvim', {'done': 'call s:ConfigSmartOpen()'}
Plug 'kkharji/sqlite.lua'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
" @url https://github.com/danielfalk/smart-open.nvim

function s:ConfigSmartOpen()
lua <<EOF
	require('smart-open').setup({
	})

	-- Map Ctrl+E to open the smart open dialog
	vim.keymap.set('n', '<c-e>', require('telescope').extensions.smart_open.smart_open, { noremap = true, silent = true })
EOF
endfunction
" }}}
" Plugin: Transparent - `:Transparent{Toggle,Enable,Disable}` {{{
Plug 'xiyaowong/transparent.nvim', {'done': 'call s:ConfigTransparent()'}
" @url https://neovimcraft.com/plugin/xiyaowong/nvim-transparent/index.html

function s:ConfigTransparent()
lua <<EOF
	require('transparent').setup({
		groups = {
			'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
			'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
			'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
			'SignColumn', 'CursorLineNr', 'EndOfBuffer',
		},
		extra_groups = {}, -- table: additional groups that should be cleared
		exclude_groups = {}, -- table: groups you don't want to clear
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
	require('nvim-treesitter.configs').setup({
		ensure_installed = {
			"bash",
			"css",
			"csv",
			"diff",
			"dockerfile",
			"gitcommit",
			"git_config",
			"gitignore",
			"html",
			"ini",
			"javascript",
			"jq",
			"jsdoc",
			"json",
			"json5",
			"just",
			"markdown",
			"nginx",
			"perl",
			"php",
			"python",
			"regex",
			"scss",
			"sql",
			"ssh_config",
			"tmux",
			"tsv",
			"typescript",
			"vim",
			"vue",
			"xml",
			"yaml",
		},
		highlight = {
			enable = true, -- false will disable the whole extension
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
	})

	require('ibl').setup({
		indent = {
			char = "│",
		},
	})

	-- `vai` to select within context, `vaI` to select + outer surround
	-- `vii` to seletc everything within the current indent
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

nmap <silent> gt :TSJToggle <CR>
nmap <silent> gs :TSJSplit <CR>
nmap <silent> gj :TSJJoin <CR>
endfunction
" }}}
" Plugin: Todo-Comments - Highlight various code comments {{{
Plug 'folke/todo-comments.nvim', {'done': 'call s:ConfigTodoComments()' }

" @FIXME: Test 0
" DEBUG: Test 1
" FIXME: Test 2
" TODO: Test 3
" WARN: Test 4

function s:ConfigTodoComments()
lua <<EOF
	require('todo-comments').setup({
		signs = true,
		sign_priority = 7, -- One higher than gitsigns so this plugin overrides
		keywords = {
			HACK = { icon = " ", color = "warning", alt = { "BUG", "KLUDGE" } },
			FIX  = { icon = " ", color = "warning", alt = { "FIXME", "BUG", "EXPERIMENTAL" } },
			NOTE = { icon = " ", color = "hint", alt = { "INFO", "UX" } },
			TODO = { icon = " ", color = "info" },
			WARN = { icon = " ", color = "error", alt = { "WARNING", "WARN", "XXX", "CRIT", "CRITICAL", "DEBUG" } },
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
	})
EOF
endfunction
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
" Plugin: Whitespace - Show whitespace characters in visual mode {{{
Plug 'mcauley-penney/visual-whitespace.nvim', {'done': 'call s:ConfigWhitespace()'}

function s:ConfigWhitespace()
lua <<EOF
	require('visual-whitespace').setup({
		enabled = true,
		space_char = '·',
		tab_char = '→',
		unix_char = '↲',
		mac_char = '←',
		dos_char = '↙',
	})
EOF
endfunction
" }}}
" Plugin: Yanky - Yankring functionality {{{
Plug 'gbprod/yanky.nvim', {'done': 'call s:ConfigYanky()'}
" @url https://github.com/gbprod/yanky.nvim

function s:ConfigYanky()
lua <<EOF
	require('yanky').setup({
		ring = {
			history_length = 100,
			storage = "shada",
			sync_with_numbered_registers = true,
			cancel_event = "move", -- Moving away from paste area cancels yanky ring selection mode
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
			sync_with_ring = false,
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
" Plugins: Post load - Init battery mode from auto {{{
autocmd VimEnter * call BatteryToggle('auto', 1)
" }}}

" Color scheme (+fixes) {{{
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
		" highlight Conceal ctermfg=81 ctermbg=none
		" Mild purple
		" highlight Conceal ctermfg=147 ctermbg=none
		" Mild red
		highlight Conceal guifg=#bf616a guibg=none ctermfg=131 ctermbg=none

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

	if g:switch_colorscheme_patch_background == 1
		highlight Normal guibg=NONE ctermbg=NONE
		highlight NonText guibg=NONE ctermbg=NONE
	endif

	if g:switch_colorscheme_patch_ale_virtualtext == 1
		highlight link ALEVirtualTextError NotifyWARNTitle
		highlight link ALEVirtualTextWarning NotifyWARNTitle
		highlight link ALEVirtualTextInfo NotifyWARNTitle
	endif

	if g:switch_colorscheme_patch_errormsg == 1
		highlight ErrorMsg ctermfg=124 guifg=#bf616a
	endif

	if g:switch_colorscheme_patch_todo == 1
		highlight Todo ctermfg=142 guifg=#9faa00 guibg=none gui=italic
	endif

	" Patch Hop colors
	highlight HopNextKey ctermfg=242 ctermbg=0 gui=bold guifg=#D8DEE9 guibg=#5E81AC
	highlight HopNextKey1 ctermfg=242 ctermbg=0 gui=bold guifg=#D8DEE9 guibg=#5E81AC
	highlight HopNextKey2 ctermfg=242 ctermbg=0 gui=bold guifg=#D8DEE9 guibg=#5E81AC

	" Patch Notify colors
	highlight NotifyERRORBorder guifg=#8A1F1F guibg=#000000
	highlight NotifyWARNBorder guifg=#79491D guibg=#000000
	highlight NotifyINFOBorder guifg=#4F6752 guibg=#000000
	highlight NotifyDEBUGBorder guifg=#8B8B8B guibg=#000000
	highlight NotifyTRACEBorder guifg=#4F3552 guibg=#000000
	highlight NotifyERRORIcon guifg=#F70067 guibg=#000000
	highlight NotifyWARNIcon guifg=#F79000
	highlight NotifyINFOIcon guifg=#A9FF68
	highlight NotifyDEBUGIcon guifg=#8B8B8B
	highlight NotifyTRACEIcon guifg=#D484FF
	highlight NotifyERRORTitle  guifg=#F70067
	highlight NotifyWARNTitle guifg=#F79000
	highlight NotifyINFOTitle guifg=#A9FF68
	highlight NotifyDEBUGTitle  guifg=#8B8B8B
	highlight NotifyTRACETitle  guifg=#D484FF
	highlight NotifyERRORBody guibg=#000000
	highlight NotifyWARNBody guibg=#000000
	highlight NotifyINFOBody guibg=#000000
	highlight NotifyDEBUGBody guibg=#000000
	highlight NotifyTRACEBody guibg=#000000
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
