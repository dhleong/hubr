
let s:unite_source = {
    \ 'name': 'gh_issue',
    \ }

function! s:unite_source.gather_candidates(args, context)

    " FIXME milestone? maybe as an arg? state?
    let issues = hubr#_python('get_issues(state="open", milestone="2.10.0")')

    if type(issues) == type(0)
        " some kind of error
        return []
    endif

    " transform to unite format stuff
    let candidates = map(issues, '{
        \ "word": v:val.number . ": " . v:val.title,
        \ "source": "gh_issue",
        \ "kind": "gh_issue",
        \ "source__issue_id": v:val.number,
        \ "source__issue_dict": v:val
        \ }')

    " calculate max name len
    let maxNameLen = 60 " TODO option
    let maxLen = 0
    for element in candidates
        " make sure it's not too long
        if len(element.word) > maxNameLen
            let element.word = strpart(element.word, 0, maxNameLen - 3) . '...'
        endif

        let maxLen = max([maxLen, len(element.word)])
    endfor

    let desiredLen = maxLen + 2
    for element in candidates
        let issue = element.source__issue_dict

        " append labels 
        if len(issue.labels)
            let labelNames = map(issue.labels, 'v:val.name')
            let element.word = element.word 
                \ . repeat(' ', desiredLen - len(element.word)) 
                \ . '[' . join(labelNames, ', ') . ']'
        endif
    endfor

    return candidates
endfunction

function! unite#sources#gh_issue#define()
    return s:unite_source
endfunction
