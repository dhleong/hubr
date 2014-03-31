" -------------------------------
"  Github Label Unite Source
"  By: Daniel Leong
" -------------------------------

let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
    \ 'name': 'gh_label',
    \ }

function! s:map_labels(labels, existing)

    " build up a lookup table
    let names = {}
    let selected = {}
    let longest = 0
    for label in a:labels
        let names[label.name] = label.name
        let selected[label.name] = 0
        let longest = max([longest, len(label.name)])
    endfor

    " update name for those 
    for label in a:existing
        let spaces = repeat(' ', longest - len(label.name))
        let names[label.name] = label.name . spaces . ' (SELECTED)'
    endfor

    " TODO gh_label kind
    return map(a:labels, '{
        \ "word": names[v:val.name],
        \ "source": "gh_label",
        \ "kind": "common",
        \ "source__label_dict": v:val,
        \ "source__label_selected": selected[v:val.name]
        \ }')
endfunction

function! s:gather_issue_labels(issueNumber)
    let issue = hubr#get_issue(a:issueNumber)
    if type(issue) == type(0)
        " some kind of error
        return []
    endif

    return s:map_labels(issue.labels, issue.labels)
endfunction

function! s:gather_all_labels(existingLabels)
    let labels = hubr#get_labels()
    if type(labels) == type(0)
        " some kind of error
        return []
    endif

    return s:map_labels(labels, a:existingLabels)
endfunction

function! s:unite_source.gather_candidates(args, context)

    let issue = get(a:context, 'action__issue_dict', {})
    if !hubr#_has_pyopt('repo_name')
        echoerr "You must either use hubr_set_options_from_fugitive, or set REPO_NAME"
        return []
    elseif len(a:args) > 0
        " the arg is an issue number
        return s:gather_issue_labels(a:args[0])
    elseif issue != {}
        " an issue dict was provided by an action
        " TODO we actually need to get all the labels,
        "  and somehow add a way to toggle specific ones,
        "  using this list to know which ones we already have
        return s:gather_all_labels(issue.labels)
    else
        " no args; just get all labels for the repo
        return s:gather_all_labels([])
    endif
endfunction

function! unite#sources#gh_label#define()
    return s:unite_source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
