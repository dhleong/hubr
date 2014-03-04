
let s:unite_source = {
    \ 'name': 'gh_issue',
    \ }

function! s:unite_source.gather_candidates(args, context)

    let repo = hubr#repo_name()
    let milestone = '2.10.0' " FIXME milestone? maybe as an arg?
    let flags = '-o' " FIXME args

    " fetch the issues
    let cmd_args = "-r " . repo . " -m " . milestone . " " . flags
    let raw_issues = hubr#_exec("github-issues-fetch", cmd_args)

    " clean it up and check for success
    let lines = split(raw_issues, '\n')
    let status = lines[1]
    if !strpart(status, 0, 4) == 'done'
        echomsg status
        return []
    endif

    " transform to [(<id>, <name>), ..]
    let issuelist = map(lines[3:], 
        \ '[strpart(v:val, 0, stridx(v:val, ":")), strpart(v:val, stridx(v:val, ":")+2)]')

    " transform to unite format stuff
    return map(issuelist, '{
        \ "word": v:val[1],
        \ "source": "gh_issue",
        \ "kind": "gh_issue",
        \ "source__issue_id": v:val[0]
        \ }')
endfunction

function! unite#sources#gh_issue#define()
    return s:unite_source
endfunction
