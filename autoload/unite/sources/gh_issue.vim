
let s:unite_source = {
    \ 'name': 'gh_issue',
    \ }

function! s:unite_source.gather_candidates(args, context)
    "let issuelist = [['2196', 'Comments for Photos'], ['2199', 'Test']]

    let repo = 'Miners/minus-for-Android' " FIXME hubr#repo_name()
    let milestone = '2.10.0' " FIXME milestone?
    let flags = '-o'

    let path = expand("%:p")
    let root = strpart(path, 0, stridx(path, 'autoload'))

    let raw_issues = system(root . "github-issues-fetch -r " . repo . " -m " . milestone . " " . flags)

    let lines = split(raw_issues, '\n')
    let status = lines[1]
    if !strpart(status, 0, 4) == 'done'
        return []
    endif

    let issuelist = map(lines[3:], 
        \ '[strpart(v:val, 0, stridx(v:val, ":")), strpart(v:val, stridx(v:val, ":")+2)]')

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
