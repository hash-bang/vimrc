" Very simple syntax for DotEnv (`.env*`) files
syn match Title /^\zs.\{-}\ze=/
syn match Comment "#.*$"

" Various values
syn match Keyword /=\s*\(false\|true\)/
syn match Integer /=\s*\d+/
