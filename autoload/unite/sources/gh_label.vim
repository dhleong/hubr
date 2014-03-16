" -------------------------------
"  Github Label Unite Source
"  By: Daniel Leong
" -------------------------------

let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
    \ 'name': 'gh_label',
    \ }

function! s:map_labels(labels)
    " TODO gh_label kind
    return map(a:labels, '{
        \ "word": v:val.name,
        \ "source": "gh_label",
        \ "kind": "common",
        \ "source__label_dict": v:val
        \ }')
endfunction

function! s:gather_issue_labels(issueNumber)
    let issue = hubr#get_issue(a:issueNumber)
    if type(issue) == type(0)
        " some kind of error
        return []
    endif

    return s:map_labels(issue.labels)
endfunction

function! s:gather_all_labels()
    let labels = hubr#get_labels()
    if type(labels) == type(0)
        " some kind of error
        return []
    endif

    return s:map_labels(labels)
endfunction

function! s:unite_source.gather_candidates(args, context)

    if !hubr#_has_pyopt('repo_name')
        echoerr "You must either use hubr_set_options_from_fugitive, or set REPO_NAME"
        return []
    elseif len(a:args) > 0
        " the arg is an issue number
        return s:gather_issue_labels(a:args[0])
    else
        " no args; just get all labels for the repo
        return s:gather_all_labels()
    endif
endfunction

function! unite#sources#gh_label#define()
    return s:unite_source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
