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
"  TAKE action  "
"""""""""""""""""
let s:kind.action_table.take = {
    \ 'description' : 'Assign the issue to yourself; requires ME_LOGIN config, or hubr_set_options_from_fugitive enabled',
    \ 'is_selectable': 0,
    \ }
function! s:kind.action_table.take.func(candidate)

    let id = a:candidate.source__issue_id
    " echomsg "View issue " . id

    if !hubr#_has_pyopt("me_login")
        echoerr "You must either enable hubr_set_options_from_fugitive, or set the ME_LOGIN config"
        return
    endif

    let me = hubr#_pyopt("me_login")
    let result = hubr#assign(id, me)
    if result.status != 200
        echoerr "Error: " . result.status
        return
    endif

    echomsg "Successfully 'took' the issue"
endfunction

""""""""""""""""""
"  LABEL action  "
""""""""""""""""""
let s:kind.action_table.label = {
    \ 'description' : 'Modify labels on the issue',
    \ 'is_selectable': 0,
    \ }
function! s:kind.action_table.label.func(candidate)

    let issue = a:candidate.source__issue_dict
    let id = a:candidate.source__issue_id
    " echomsg "View issue " . id

    if !hubr#_has_pyopt("me_login")
        echoerr "You must either enable hubr_set_options_from_fugitive, or set the ME_LOGIN config"
        return
    endif

    call unite#start(['gh_label'], {'action__issue_dict': issue})
endfunction

"""""""""""""""""
"  VIEW action  "
"""""""""""""""""
let s:kind.action_table.view = {
    \ 'description' : 'Open issue in browser',
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
    \ 'description' : 'Insert "Closes #<num>" for selected issues',
    \ 'is_selectable': 1,
    \ }
function! s:kind.action_table.annotate_closes.func(candidates)
    call s:annotate(a:candidates, 'Closes', 0)
endfunction

""""""""""""""""""""""""""
"  ANNOTATE-REFS action  "
""""""""""""""""""""""""""
let s:kind.action_table.annotate_refs = {
    \ 'description' : 'Insert "Refs #<num>" for selected issues',
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
