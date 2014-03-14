''' ------------------------------------------------------------------------
Python initialization
---------------------------------------------------------------------------
here we initialize the hubr stuff '''

import vim
import json

# update the system path, to include the hubr path
import sys
import os

# vim.command('echom expand("<sfile>:p:h:h")') # broken, <sfile> inside function
# sys.path.insert(0, os.path.join(vim.eval('expand("<sfile>:p:h:h")'), 'hubr'))
sys.path.insert(0, os.path.join(vim.eval('expand(s:script_path)'), 'hubr'))

# to display errors correctly
import traceback

# update the sys path to include the hubr script
sys.path.insert(0, vim.eval('expand(s:script_path)'))
try:
    from hubr import Hubr, HubrResult
except ImportError:
    vim.command('echoerr "Failed to initialize Hubr"')
sys.path.pop(1)



class PythonToVimStr(unicode):
    """ Vim has a different string implementation of single quotes.
    Borrowed from jedi-vim"""
    __slots__ = []

    def __new__(cls, obj, encoding='UTF-8'):
        if isinstance(obj, unicode):
            return unicode.__new__(cls, obj)
        else:
            return unicode.__new__(cls, obj, encoding)

    def __repr__(self):
        # this is totally stupid and makes no sense but vim/python unicode
        # support is pretty bad. don't ask how I came up with this... It just
        # works...
        # It seems to be related to that bug: http://bugs.python.org/issue5876
        if unicode is str:
            s = self
        else:
            s = self.encode('UTF-8')
        return '"%s"' % s.replace('\\', '\\\\').replace('"', r'\"')

__hubrs = {}
def hubr(repoPath):
    if __hubrs.has_key(repoPath):
        return __hubrs[repoPath]

    newHubr = Hubr.from_config(repoPath + '.hubrrc')
    __hubrs[repoPath] = newHubr
    return newHubr

def _vimify(obj):
    """Convert a dict, list, etc. into a vim-consumable format"""
    if type(obj) == dict:
        d = vim.bindeval("{}")
        for key, val in obj.iteritems():
            key = str(key)
            try: 
                d[key] = _vimify(val)
            except TypeError, e:
                print "Failed to convert ", val
                raise e
        return d

    elif type(obj) == list:
        l = vim.bindeval("[]")
        l.extend(map(_vimify, obj))
        return l

    elif type(obj) == unicode or type(obj) == str:
        return PythonToVimStr(obj)

    elif obj is None:
        return 0
    
    return obj

def hubr_to_vim(bindName, result):
    if type(result) == HubrResult:
        result = {
            'status': result.get_status(),
            'json': result.json()
        }

    d = vim.bindeval(bindName)
    vimified = _vimify(result)
    d['result'] = vimified
