" These are the mappings for snipMate.vim. Putting it here ensures that it
" will be mapped after other plugins such as supertab.vim.
if !exists('loaded_snips')
	finish
endif

function! s:RecordPosition()
	" The position record consists of the current cursor position and the buffer
	" number. When this position record is assigned to a window-local variable,
	" it is also linked to the current window and tab page.
	return getpos('.') + [bufnr('')]
endfunction
function! s:SetTriggerPosition()
	let w:snipMate_TriggerPosition = s:RecordPosition()
	return ''
endfunction

if v:version == 703 && has('patch489') || v:version > 703
" Patch 7.3.489 fixes that CTRL-] in Insert mode does not expand abbreviation
" when used in a mapping. We can now record the cursor position, trigger the
" abbreviation via :map-expr, and after that compare the cursor position to
" determine whether snipMate should be triggered.
function! TriggerFilter( expr )
	if a:expr ==# "\<C-]>"
		" No snippet was expanded.
		let l:lastSnipMateExpansionPosition = (exists('s:lastSnipMateExpansionPosition') ? s:lastSnipMateExpansionPosition : [])
		let s:lastSnipMateExpansionPosition = []
		if s:RecordPosition() == l:lastSnipMateExpansionPosition
			" We had reached at the end of a snippet before; now leave insert
			" mode.
			return "\<C-\>\<C-n>"
		else
			" Beep to notify that neither snipMate nor Vim abbreviation were
			" expanded.
			return "\<C-\>\<C-o>\<Esc>"
		endif
	else
		let s:lastSnipMateExpansionPosition = s:RecordPosition()
		return a:expr
	endif
endfunction
function! s:TriggerAbbreviation()
	let s:triggerPos = getpos('.')
	return "\<C-]>"
endfunction
function! TriggerSnippetAfterExpand()
	if getpos('.') == s:triggerPos
		" No Vim abbreviation was expanded.
		if exists('w:snipMate_TriggerPosition') && w:snipMate_TriggerPosition == s:RecordPosition()
			" Expansion was attempted at the same position before; leave insert
			" mode.
			return "\<C-\>\<C-n>"
		else
			" Attempt snipMate snippet expansion.
			call s:SetTriggerPosition()
			return TriggerFilter(TriggerSnippet())
		endif
	else
		call s:SetTriggerPosition()
		return ''
	endif
endfunction
inoremap <expr> <SID>(TriggerAbbreviation) <SID>TriggerAbbreviation()
inoremap <silent> <script> <C-]> <SID>(TriggerAbbreviation)<c-r>=TriggerSnippetAfterExpand()<cr>
else
" The only way to trigger the expansion of abbreviations is via a direct :imap,
" where the <C-]> must come first to avoid recursion. When no abbreviation has
" been expanded, the ^] character is inserted literally in the text. We check
" for that character, remove it, and then trigger snipMate.
function! TriggerFilter( expr )
	if a:expr ==# "\<C-]>"
		" No snippet was expanded.

		" In case of a failed Vim abbreviation expansion, beep to notify the
		" user. Otherwise, we're at the end of a snippet; do nothing in this
		" case.
		let l:keys = (exists('s:wasSnipMateExpansion') && s:wasSnipMateExpansion ? '' : "\<C-\>\<C-o>\<Esc>")
		let s:wasSnipMateExpansion = 0

		if exists('w:snipMate_TriggerPosition') && w:snipMate_TriggerPosition == s:RecordPosition()
			" Expansion was attempted at the same position before; leave insert
			" mode.
			return "\<C-\>\<C-n>"
		else
			return l:keys
		endif
	else
		let s:wasSnipMateExpansion = 1
		return a:expr
	endif
endfunction
function! TriggerSnippetAfterExpand()
	let l:lastInsertedChar = matchstr(getline('.'), '.\%' . col('.') . 'c')
	if l:lastInsertedChar ==# "\<C-]>"
		" No Vim abbreviation was expanded.
		if exists('w:snipMate_TriggerPosition') && w:snipMate_TriggerPosition == s:RecordPosition()
			" Expansion was attempted at the same position before; leave insert
			" mode.
			return "\<BS>\<C-\>\<C-n>"
		else
			" Attempt snipMate snippet expansion.
			return "\<BS>\<C-r>=TriggerFilter(TriggerSnippet())\<CR>"
		endif
	else
		return ''
	endif
endfunction
imap <silent> <C-]> <C-]><c-r>=TriggerSnippetAfterExpand()<cr><SID>(RecordPosition)
endif

let g:snipMate_triggerKey = "\<C-]>"
let g:snipMate_reverseTriggerKey = "\<C-\>"
noremap  <silent> <expr> <SID>(RecordPosition) ''
inoremap <silent> <expr> <SID>(RecordPosition) <SID>SetTriggerPosition()
snor <silent> <C-]> <esc>i<right><c-r>=TriggerFilter(TriggerSnippet())<cr>
ino  <silent> <C-\> <c-r>=TriggerFilter(BackwardsSnippet())<cr>
snor <silent> <C-\> <esc>i<right><c-r>=TriggerFilter(BackwardsSnippet())<cr>
" Superseded by the superior SnippetCompleteSnipMate.vim.
"ino  <silent> <C-x>% <c-r>=ShowAvailableSnips()<cr>

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
