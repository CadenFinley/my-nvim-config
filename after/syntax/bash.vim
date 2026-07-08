if expand('%:e') ==# 'cjsh' || expand('%:t') =~# '^\.cjsh\(rc\|env\|profile\|logout\)$'
  syntax keyword cjshBuiltin approot cjshopt abbr unabbr restart hook version
  syntax match cjshBuiltin /\<\(generate-completions\|cjsh-widget\)\>/
  highlight default link cjshBuiltin Keyword
endif
