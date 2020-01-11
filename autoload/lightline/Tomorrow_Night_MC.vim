" MC version of Tomorrow night
" This uses the central bar for color instead of just the far left hand side

let s:base3 = '#c5c8c6'
let s:base2 = '#bababa'
let s:base1 = '#a0a0a0'
let s:base0 = '#909090'
let s:base00 = '#666666'
let s:base01 = '#555555'
let s:base02 = '#434343'
let s:base023 = '#303030'
let s:base03 = '#1d1f21'
let s:red = '#cc6666'
let s:orange = '#de935f'
let s:yellow = '#f0e974'
let s:green = '#58bd69'
let s:cyan = '#8abeb7'
let s:blue = '#4d8abe'
let s:magenta = '#af89bb'

let s:p = {'normal': {}, 'command': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.error = [ [ s:red, s:base023 ] ]
let s:p.normal.left = [ [ s:base02, s:base0 ], [ s:base1, s:base01 ] ]
let s:p.normal.middle = [ [ s:base02, s:blue ] ]
let s:p.normal.right = [ [ s:base02, s:base0 ], [ s:base1, s:base01 ] ]
let s:p.normal.warning = [ [ s:yellow, s:base02 ] ]

let s:p.command.middle = [ [ s:base02, s:yellow ] ]

let s:p.inactive.middle = [ [ s:base0, s:base02 ] ]

let s:p.insert.middle = [ [ s:base02, s:green ] ]

let s:p.replace.middle = [ [ s:base02, s:orange ] ]

let s:p.tabline.left = [ [ s:base2, s:base01 ] ]
let s:p.tabline.middle = [ [ s:base01, s:base0 ] ]
let s:p.tabline.right = copy(s:p.normal.right)
let s:p.tabline.tabsel = [ [ s:base2, s:base023 ] ]

let s:p.visual.middle = [ [ s:base02, s:magenta ] ]

let g:lightline#colorscheme#Tomorrow_Night_MC#palette = lightline#colorscheme#fill(s:p)
