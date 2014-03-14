function! s:python(methodCall)
    let repo_path = hubr#repo_path()
    let fullCall = 'hubr("' . repo_path . '").' . a:methodCall

    let python_result = {}
    exe 'python hubr_to_vim("python_result", ' . fullCall . ')'
    return python_result
endfunction

function! hubr#repo_path() 

    if !exists("*fugitive#repo")
        echo "Github view requires vim-fugitive plugin"
        return 0
    endif

    let git_dir = fugitive#repo().git_dir
    let end = stridx(git_dir, '/.git')
    return strpart(git_dir, 0, end+1)
endfunction

function! hubr#repo_name() 

    if !exists("*fugitive#repo")
        echo "Github view requires vim-fugitive plugin"
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

function! hubr#_exec(cmd, args)
    let path = expand("%:p")
    let root = strpart(path, 0, stridx(path, 'autoload'))

    return system(root . a:cmd . ' ' . a:args)
endfunction

function! hubr#get_user(...)
    if a:0 == 1
        echo s:python('get_user("' . a:1 . '")')
    else
        echo  s:python('get_user()')
    endif
endfunction

" ------------------------------------------------------------------------
" Python initialization
" ------------------------------------------------------------------------

let s:repo_path = hubr#repo_path()
let s:script_path = fnameescape(expand('<sfile>:p:h:h'))
execute 'pyfile '.s:script_path.'/hubr_vim.py'
