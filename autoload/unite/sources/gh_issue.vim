
let s:unite_source = {
    \ 'name': 'gh_issue',
    \ }

function! s:unite_source.gather_candidates(args, context)
    let issuelist = [['2196', 'Comments for Photos'], ['2199', 'Test']]

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
