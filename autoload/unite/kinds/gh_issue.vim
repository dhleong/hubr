let s:kind = {
    \ 'name': 'gh_issue',
    \ 'default_action': 'view',
    \ 'action_table': {},
    \ 'parents': [],
    \ }
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

function! unite#kinds#gh_issue#define()
    return s:kind
endfunction
