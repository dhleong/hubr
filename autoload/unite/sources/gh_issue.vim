
let s:unite_source = {
    \ 'name': 'gh_issue',
    \ }

function! s:unite_source.gather_candidates(args, context)

    " FIXME milestone? maybe as an arg? state?
    let issues = hubr#_python('get_issues(state="open", milestone="2.10.0")')

    " transform to unite format stuff
    return map(issues, '{
        \ "word": v:val.number . ": " . v:val.title,
        \ "source": "gh_issue",
        \ "kind": "gh_issue",
        \ "source__issue_id": v:val.number
        \ }')
endfunction

function! unite#sources#gh_issue#define()
    return s:unite_source
endfunction
