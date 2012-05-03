" These are the mappings for snipMate.vim. Putting it here ensures that it
" will be mapped after other plugins such as supertab.vim.
if !exists('loaded_snips') || exists('s:did_snips_mappings')
	finish
endif
let s:did_snips_mappings = 1

function! TriggerFilter( expr )
	return (a:expr ==# "\<C-]>" ? '' : a:expr)
endfunction
function! TriggerSnippetAfterExpand()
	let l:lastInsertedChar = matchstr(getline('.'), '.\%' . col('.') . 'c')
	return (l:lastInsertedChar ==# "\<C-]>" ? "\<BS>\<C-r>=TriggerFilter(TriggerSnippet())\<CR>" : '')
endfunction

let g:snipMate_triggerKey = "\<C-]>"
let g:snipMate_reverseTriggerKey = "\<C-\>"
imap <silent> <C-]> <C-]><c-r>=TriggerSnippetAfterExpand()<cr>
snor <silent> <C-]> <esc>i<right><c-r>=TriggerFilter(TriggerSnippet())<cr>
ino  <silent> <C-\> <c-r>=TriggerFilter(BackwardsSnippet())<cr>
snor <silent> <C-\> <esc>i<right><c-r>=TriggerFilter(BackwardsSnippet())<cr>
ino  <silent> <C-r><C-]> <c-r>=ShowAvailableSnips()<cr>

" Without this, you cannot move to the next tab stop after clearing a
" placeholder with <BS>.
snor <bs> b<bs>

" The default mappings for these are annoying & sometimes break snipMate.
" You can change them back if you want, I've put them here for convenience.
"snor <bs> b<bs>
"snor <right> <esc>a
"snor <left> <esc>bi
"snor ' b<bs>'
"snor ` b<bs>`
"snor % b<bs>%
"snor U b<bs>U
"snor ^ b<bs>^
"snor \ b<bs>\
"snor <c-x> b<bs><c-x>

" By default load snippets in snippets_dir
if empty(snippets_dir)
	finish
endif

call GetSnippets(snippets_dir, '_') " Get global snippets

au FileType * if &buftype !=# 'help' && &buftype !=# 'quickfix' | call GetSnippets(snippets_dir, &ft) | endif
" vim:noet:sw=4:ts=4:ft=vim
