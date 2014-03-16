
let s:unite_source = {
    \ 'name': 'gh_issue',
    \ }

function! s:unite_source.gather_candidates(args, context)

    let issuesFilter = {}
    for arg in a:args
        let lastChar = len(arg) - 1
        let useOpt = arg[lastChar] == '?'
        let eq = stridx(arg, '=')
        if eq == -1 && useOpt
            " hubrrc opt
            let opt = strpart(arg, 0, lastChar)
            let val = hubr#_pyopt(opt)
            if hubr#_has_pyopt(opt) " safely handle un-set opt
                let issuesFilter[opt] = val
            endif
        elseif eq != -1
            " key=val
            let key = strpart(arg, 0, eq)
            let value = strpart(arg, eq+1)
            let issuesFilter[key] = value
        else
            " notify error
            call unite#print_error('invalid gh_issues arg ' . arg)
        endif
    endfor

    let issues = hubr#get_issues(issuesFilter)

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
    let maxNameLen = 60 " TODO evenly split screen width
    let maxLen = 0
    let maxAssigneeLen = 0
    for element in candidates
        let issue = element.source__issue_dict

        " make sure it's not too long
        if len(element.word) > maxNameLen
            let element.word = strpart(element.word, 0, maxNameLen - 3) . '...'
        endif

        let maxLen = max([maxLen, len(element.word)])

        if type(issue.assignee) != type(0)
            let maxAssigneeLen = max([maxAssigneeLen, len(issue.assignee.login)])
        endif
    endfor

    let desiredTitleLen = maxLen + 2
    let desiredUserLen = maxAssigneeLen + 2
    for element in candidates
        let issue = element.source__issue_dict

        " pad out the title, always
        let element.word = element.word 
            \ . repeat(' ', desiredTitleLen - len(element.word)) 

        " add assignee
        if type(issue.assignee) != type(0)
            let element.word = element.word 
                \ . '(' . issue.assignee.login . ')'
                \ . repeat(' ', desiredUserLen - len(issue.assignee.login))
        else
            " +2 for the missing parens 
            let element.word = element.word
                \ . repeat(' ', desiredUserLen + 2) 
        endif

        " append labels 
        if len(issue.labels)
            let labelNames = map(issue.labels, 'v:val.name')
            let element.word = element.word 
                \ . '[' . join(labelNames, ', ') . ']'
        endif
    endfor

    return candidates
endfunction

function! unite#sources#gh_issue#define()
    return s:unite_source
endfunction
