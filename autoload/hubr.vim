

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
