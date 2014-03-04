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

    if !exists("*fugitive#repo")
        echo "Github view requires vim-fugitive plugin"
        return
    endif

    let remote = fugitive#repo().config('remote.origin.url')

    let url = ''
    if strpart(remote, 0, 3) == 'ssh'
        let start = stridx(remote, '.com/') + 5
        let end = stridx(remote, '.git')

    elseif strpart(remote, 0, 4) == 'http'
        " TODO
        echomsg "Incomplete: " . remote
        return
    else
        let start = stridx(remote, ':') + 1
        let end = strridx(remote, '.git')
    endif

    let url = "http://github.com/" . strpart(remote, start, end - start)
    let url = url . '/issues/' . id
    echomsg "Opening " . url
    silent exe "!open " . url
endfunction

function! unite#kinds#gh_issue#define()
    return s:kind
endfunction
