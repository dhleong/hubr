" ------------------------------------------------------------------------
" Autocmds
" ------------------------------------------------------------------------
function! Hubr_GithubCommitRefInsert()
    if !(hubr#is_github_repo() 
            \ && hubr#has_unite()
            \ && hubr#_opt('hubr_auto_ref_issues_in_commit'))
        return
    endif

    let line = getline('.')
    let word = strpart(line, 0, len(line))
    if tolower(word) == 'refs#'
        let command = 'refs'
    elseif tolower(word) == 'closes#'
        let command = 'closes'
    else
        " nothing to do
        return
    endif

    " kill the refs# line and move cursor up for the paste
    norm ddk

    " prepare the command...
    let command = 'Unite gh_issue:' . hubr#_opt('hubr_auto_ref_issues_args') 
        \ . ' -start-insert'
        \ . ' -default-action=annotate_' . command 

    " ... and run it!
    exe command

    " for some reason, start-insert adds some garbage to the input.
    " this magical incantation seems to help (although I can't seem
    " to get the prompt to show up correctly
    norm cc
endfunction

augroup hubr_GithubCommit
    autocmd!
    autocmd CursorMovedI COMMIT_EDITMSG call Hubr_GithubCommitRefInsert()
augroup END


