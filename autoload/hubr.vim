" ------------------------------------------------------------------------
" Script-local utilities
" ------------------------------------------------------------------------

function! s:python(methodCall)
    let repo_path = hubr#repo_path()
    let fullCall = 'hubr("' . repo_path . '").' . a:methodCall

    let python_result = {}
    exe 'python hubr_to_vim("python_result", ' . fullCall . ')'

    " results are returned in the 'result' key
    return python_result.result
endfunction

" Given an options dict, convert it into python kwargs calls
function! s:kwargs(options)
    return join(
        \ map(items(a:options), 
            \'v:val[0] . "=\"" . v:val[1] . "\""'), 
        \ ', ')
endfunction

function! s:ensure_fugitive()

    if !exists("*fugitive#repo")
        echoerr "hubr requires vim-fugitive plugin"
        return 0
    endif

    return 1
endfunction

" ------------------------------------------------------------------------
" Utility methods
" ------------------------------------------------------------------------

function! hubr#has_unite()
    return exists("*unite#start")
endfunction

" Check if the current repo is actually for github
function! hubr#is_github_repo()
    let origin = fugitive#repo().config('remote.origin.url')
    return stridx(origin, "github.com") != -1
endfunction

" Convenience to get the repo user's 'login' name
"  (for conveniences like assigning a ticket to yourself)
function! hubr#me_login()

    if !s:ensure_fugitive()
        return 0
    endif

    let fullUser = fugitive#repo().user()
    let space = stridx(fullUser, ' ')
    if space == -1
        return fullUser
    endif

    return strpart(fullUser, 0, space)
endfunction


function! hubr#repo_path() 

    if !s:ensure_fugitive()
        return 0
    endif

    let git_dir = fugitive#repo().git_dir
    let end = stridx(git_dir, '/.git')
    return strpart(git_dir, 0, end+1)
endfunction

function! hubr#repo_name() 

    if !s:ensure_fugitive()
        return 0
    endif

    let remote = fugitive#repo().config('remote.origin.url')

    let url = ''
    if strpart(remote, 0, 3) == 'ssh'
        let start = stridx(remote, '.com/') + 5
        let end = stridx(remote, '.git')

    elseif strpart(remote, 0, 4) == 'http'
        " TODO
        echomsg "Incomplete: " . remote
        return 0
    else
        let start = stridx(remote, ':') + 1
        let end = strridx(remote, '.git')
    endif

    return strpart(remote, start, end - start)
endfunction

" ------------------------------------------------------------------------
" Hubr API methods
" ------------------------------------------------------------------------

" Options is a dict whose keys match kwargs
"  for the same method in the Python Hubr
function! hubr#get_issues(options)
    let args = s:kwargs(a:options)
    return s:python('get_issues(' . args . ')')
endfunction

function! hubr#get_user(...)
    if a:0 == 1
        echo s:python('get_user("' . a:1 . '")')
    else
        echo s:python('get_user()')
    endif
endfunction


" ------------------------------------------------------------------------
" 'Private' methods
" ------------------------------------------------------------------------

" @deprecated
function! hubr#_exec(cmd, args)
    let path = expand("%:p")
    let root = strpart(path, 0, stridx(path, 'autoload'))

    return system(root . a:cmd . ' ' . a:args)
endfunction

" Get value of an option
function! hubr#_opt(optName)
    let globalName = 'g:hubr#' . a:optName
    let localName = 'b:hubr#' . a:optName
    if exists(localName)
        return eval(localName)
    elseif exists(globalName)
        return eval(globalName)
    else
        return s:opt_defaults[a:optName]
    endif
endfunction

" Check if we have an option on the Python Hubr instance
function! hubr#_has_pyopt(optName)
    return s:python('has_option("' . a:optName . '")')
endfunction

" Get value of option on the Python Hubr instance
function! hubr#_pyopt(optName)
    return s:python('get_option("' . a:optName . '")')
endfunction

" Low-level access to the python call
function! hubr#_python(methodCall)
    return s:python(a:methodCall)
endfunction

" ------------------------------------------------------------------------
" Options
" ------------------------------------------------------------------------
let s:opt_defaults = {
    \ 'hubr_set_options_from_fugitive': 1,
    \ 'hubr_auto_ref_issues_in_commit': 1,
    \ 'hubr_auto_ref_issues_args': 'state=open:milestone?'
\}

" ------------------------------------------------------------------------
" Python initialization
" ------------------------------------------------------------------------

let s:repo_path = hubr#repo_path()
let s:script_path = fnameescape(expand('<sfile>:p:h:h'))
execute 'pyfile '.s:script_path.'/hubr_vim.py'
