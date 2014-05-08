" ------------------------------------------------------------------------
" Autocmds
" ------------------------------------------------------------------------
function! Hubr_GithubCommitRefInsert()
    if !(hubr#is_github_repo() 
            \ && hubr#has_unite()
            \ && hubr#_opt('auto_ref_issues_in_commit'))
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
    let command = 'Unite gh_issue:' . hubr#_opt('auto_ref_issues_args') 
        \ . ' -default-action=annotate_' . command 

    " ... and run it!
    exe command
endfunction

augroup hubr_GithubCommit
    autocmd!
    autocmd CursorMovedI COMMIT_EDITMSG call Hubr_GithubCommitRefInsert()
augroup END


"
" NB: This was an experiment at using threads and omnicomplete for 
"  issue completion, but I want to be able to filter on the title
"  as well as the number, but to only insert the number; I don't
"  think omnicomplete allows for that :(
" Still, the code is left in place for reference in the future if
"  I want to, say, prefetch the issues list, or if I change my mind
"

"
" let s:hubr_omnicomplete_list = []
"
" function! HubrTestFunc()
"     echo s:hubr_omnicomplete_list
" endfunction
"
" command! HubrTest call HubrTestFunc()
"
" function! Hubr_InitIssues()
"     if !hubr#is_github_repo()
"         " nothing to do
"         return
"     endif
"
"     " start fetching
"     let repo_path = hubr#repo_path()
"     exe 'python prepare_omnicomplete("' . repo_path . '")'
"
"     " TODO prepare
" endfunction
"
" augroup hubr_GithubCommit
"     autocmd!
"     autocmd BufEnter COMMIT_EDITMSG call Hubr_InitIssues()
" augroup END
"
" " ------------------------------------------------------------------------
" " Python initialization
" " ------------------------------------------------------------------------
"
" let s:repo_path = hubr#repo_path()
" let s:script_path = fnameescape(expand('<sfile>:p:h:h'))
" execute 'pyfile '.s:script_path.'/hubr_vim.py'

