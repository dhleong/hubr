" -------------------------------
"  Github Label Unite Source
"  By: Daniel Leong
" -------------------------------

let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
    \ 'name': 'gh_label',
    \ }

function! s:map_labels(labels, issue)
    
    " TODO gh_label kind
    let myLabels = copy(a:labels)
    let candidates = map(myLabels, '{
            \ "word": v:val.name,
            \ "source": "gh_label",
            \ "kind": "common",
            \ "source__label_dict": v:val
            \ }')

    if type(a:issue) == type({}) && a:issue != {} 
        " we want to act on labels for a specific issue

        let maxLen = 0
        for candidate in myLabels
            let maxLen = max([maxLen, len(candidate.word)])

            " determine if the issue is added to the candidate
            let candidate.isAdded = 0

            " I *could* build up a look-up table,
            "  but this is probably fast enough
            for addedLabel in a:issue.labels
                if addedLabel.name == candidate.word
                    let candidate.isAdded = 1
                    break
                endif
            endfor
        endfor

        let desiredTitleLen = maxLen + 2
        for element in candidates
            let element.word = element.word
                \ . repeat(' ', desiredTitleLen - len(element.word))
                \ . (element.isAdded ? "<ADDED>" : "")

            let element.source__label_is_added = element.isAdded
            let element.source__issue_dict = a:issue
        endfor
    endif

    return candidates
endfunction

function! s:gather_issue_labels(issueNumber)
    let issue = hubr#get_issue(a:issueNumber)
    if type(issue) == type(0)
        " some kind of error
        return []
    endif

    return s:map_labels(issue.labels, issue)
endfunction

function! s:gather_all_labels(issue)
    let labels = hubr#get_labels()
    if type(labels) == type(0)
        " some kind of error
        return []
    endif

    return s:map_labels(labels, a:issue)
endfunction

function! s:unite_source.gather_candidates(args, context)

    let issue = get(a:context, 'action__issue_dict', {})
    if !hubr#_has_pyopt('repo_name')
        echoerr "You must either use hubr#set_options_from_fugitive, or set REPO_NAME"
        return []
    elseif len(a:args) > 0
        " the arg is an issue number
        return s:gather_issue_labels(a:args[0])
    else
        " no args; just get all labels for the repo
        " (but, we MIGHT have passed an issue to modify
        "  in the context)
        return s:gather_all_labels(issue)
    endif
endfunction

function! unite#sources#gh_label#define()
    return s:unite_source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
