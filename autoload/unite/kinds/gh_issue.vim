"
" gh_issue Unite 'Kind' definition
"

"""""""""""
"  Utils  "
"""""""""""

function! s:annotate(candidates, type, repeats)
    let separator = '; '
    let outputString = ''
    let type = a:type

    if a:repeats
        let separator = ', '
        let outputString = a:type 
        let type = ''
    endif

    for candidate in a:candidates
        if outputString != '' && outputString != a:type
            let outputString = outputString . separator
        endif

        let id = candidate.source__issue_id
        let outputString = outputString . type . ' #' . id
    endfor

    put=outputString
endfunction

""""""""""""""""
"  Definition  "
""""""""""""""""

let s:kind = {
    \ 'name': 'gh_issue',
    \ 'default_action': 'view',
    \ 'action_table': {},
    \ 'parents': [],
    \ }

"""""""""""""""""
"  VIEW action  "
"""""""""""""""""
let s:kind.action_table.view = {
    \ 'is_selectable': 0,
    \ }
function! s:kind.action_table.view.func(candidate)

    let id = a:candidate.source__issue_id
    " echomsg "View issue " . id

    let repoName = hubr#repo_name()

    let url = "http://github.com/" . repoName . '/issues/' . id
    echomsg "Opening " . url
    silent exe "!open " . url
endfunction

""""""""""""""""""""""""""""
"  ANNOTATE-CLOSES action  "
""""""""""""""""""""""""""""
let s:kind.action_table.annotate_closes = {
    \ 'is_selectable': 1,
    \ }
function! s:kind.action_table.annotate_closes.func(candidates)
    call s:annotate(a:candidates, 'Closes', 0)
endfunction

""""""""""""""""""""""""""
"  ANNOTATE-REFS action  "
""""""""""""""""""""""""""
let s:kind.action_table.annotate_refs = {
    \ 'is_selectable': 1,
    \ }
function! s:kind.action_table.annotate_refs.func(candidates)
    call s:annotate(a:candidates, 'Refs', 1)
endfunction



"""""""""""""
"  Publish  "
"""""""""""""
function! unite#kinds#gh_issue#define()
    return s:kind
endfunction
