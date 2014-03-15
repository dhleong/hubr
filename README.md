# hubr

Super simple github commandline tools, for fun, productivity, and Vim

## Setup
Generate an oauth token from your GitHub account settings, then create a 
`.hubrrc` in your home directory. The vim commands for hubr will also look 
for a `.hubrrc` in the root directory of the current git repo, and any
configs there will override the global one. See **Vim Usage** below

Sample:

```bash
TOKEN="your-token-here"
REPO_NAME="dhleong/hubr"
ME_LOGIN="dhleong"
```

hubr can be installed as a vim plugin using Vundle:

```vim
" most features rely on tpope's amazing fugitive;
" it may become an optional dependency in the future,
" but for now it's required
Bundle 'tpope/vim-fugitive'
Bundle 'dhleong/hubr'
```

## Vim Usage

The included vim plugin provides direct access to the Github API
from pure vimscript. The vimscript methods, by default, override
most settings from the `.hubrrc` file based on the current repo,
such as `REPO_NAME` and `ME_LOGIN`, so you don't need to include
those in your `.hubrrc` unless you plan to use `hubr.py` as a terminal
command.

### hubr function examples

```vim
" kwarg methods like get_issues take a vim dict
let issues = hubr#get_issues({'milestone': '1.0'})

" the returned value is a native vim object mirroring the json
for issue in issues
    echo issue.number . ': ' . issue.title

    " null/None is represented by 0
    if type(issue.assignee) == type(0)
        echo "No assignee"
    endif
endfor
```

### Unite.vim plugin

In addition to the API accessor methods, hubr provides a new `gh_issue`
kind to [Unite.vim](http://github.com/shougo/unite.vim), which lets
you quickly access and interact with issues in your Github repo. 

For example:

```vim
nnoremap ghi :Unite gh_issue<cr>
```

Will let you type `ghi` in normal mode to call up a Unite window
that lists issues from GitHub. The default action uses `open` to
open the issue in a browser; you can also use it from `git commit`
to insert the `Refs` or `Closes` messages for one or more issues.

## Command Usage

*NOTE: The shell scripts should be considered deprecated in favor of 
the new python script, hubr.py. As soon as it supports arguments
for terminal execution, the examples will be updated*

Here are some examples:

* Assign a ticket to yourself:
`gh-cmd accept 9001`

* Add a tag (say, "Accepted"):
`gh-cmd tag 9001 Accepted"`

I do this enough that there's a shortcut: `gh-cmd accept <issue-number>`.
