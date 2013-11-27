hubr
====

Super simple github commandline tools, for fun and productivity (and maybe vim)

### Setup
Generate an oauth token from your GitHub account settings, then create a .hubrrc in your home directory. 

Sample:

```bash
TOKEN="your-token-here"
REPO_NAME="dhleong/hubr"
ME_SLUG="dhleong"
```

### Usage

Here are some examples:

* Assign a ticket to yourself:
`gh-cmd accept 9001`

* Add a tag (say, "Accepted"):
`gh-cmd tag 9001 Accepted"`

I do this enough that there's a shortcut: `gh-cmd accept <issue-number>`.

### Todo
Automatically pick repo name from pwd
Move the "accepted" label name to .hubrrc
