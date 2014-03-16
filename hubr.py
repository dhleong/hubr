#!/usr/bin/env python

from os.path import expanduser, isfile
from urllib import urlencode, quote_plus
import urllib2
import json as JSON

BASE_URL = "https://api.github.com/"
DEFAULT_HUBRRC = '~/.hubrrc'

class HubrResult(object):

    """Simple API Result wrapper for Hubr"""

    def __init__(self, requestResult, error=None):
        """Wrap the result of an HTTP request

        :requestResult: the result instance

        """
        self._requestResult = requestResult
        self._error = error

    def get_status(self):
        """
        :returns: The result code

        """
        if self._requestResult:
            return self._requestResult.getcode()

        else:
            return self._error.code
        
    def json(self):
        """Get the json response
        :returns: a dict of the JSON response,
            or None if the API call failed

        """
        if self._requestResult:
            return JSON.loads(self._requestResult.read())

        return None


def validated_data(fn):
    """Decorate a method that takes data"""
    def wrapped(self, url, params=None, json=None):
        hasParams = params is not None
        hasJson = json is not None

        if not (hasParams or hasJson):
            raise Exception("You must provide either params or json")

        elif hasParams and hasJson:
            raise Exception("You cannot provide BOTH params AND json!")

        elif hasJson:
            # format it
            json = JSON.dumps(json)

        return fn(self, url, params, json)

    return wrapped

def format_date(date):
    """Format a Python datetime obj to github's date format"""
    return date.isoformat() # convenient!

class Http(object):

    """Http-layer for Github API calls"""

    def __init__(self, token):
        """Construct a new Http instance

        :token: Github auth token

        """
        self._token = token

        self._opener = urllib2.build_opener(urllib2.HTTPSHandler)

    def delete(self, url):
        """DELETE the URL

        :url: the URL fragment to DELETE
        :returns: a HubrResult instance

        """
        return self._request("DELETE", url)

    def get(self, url):
        """GET the URL.

        :url: The URL fragment to fetch
        :returns: a HubrResult instance

        """
        return self._request("GET", url)

    @validated_data
    def patch(self, url, params=None, json=None):
        """PATCH some data to the URL. Use the kwars
        params or json for whichever kind of data you
        need to send, but providing both, or not
        providing either, will raise an Exception

        :params: A dict of params to be url-encoded
        :json: A dict or array to be json-encoded
        :returns: A HubrResult

        """

        return self._request("PATCH", url, params, json)

    @validated_data
    def post(self, url, params=None, json=None):
        """POST some data to the URL. Use the kwars
        params or json for whichever kind of data you
        need to send, but providing both, or not
        providing either, will raise an Exception

        :params: A dict of params to be url-encoded
        :json: A dict or array to be json-encoded
        :returns: A HubrResult

        """

        return self._request("POST", url, params, json)

    @validated_data
    def put(self, url, params=None, json=None):
        """PUT some data to the URL. Use the kwars
        params or json for whichever kind of data you
        need to send, but providing both, or not
        providing either, will raise an Exception

        :params: A dict of params to be url-encoded
        :json: A dict or array to be json-encoded
        :returns: A HubrResult

        """

        return self._request("PUT", url, params, json)


    def json(self, url):
        """Shortcut to GET the json at URL.

        :url: The URL fragment to fetch
        :returns: a HubrResult instance

        """
        return self.get(url).json()
        
    def _request(self, method, url, params=None, body=None):
        """Prepare a request, optionally with params or body.
        Throws an HTTPError ONLY on 401

        :method: GET/POST/PUT
        :url: everything after https://api.github.com/
        :params: Optional, dict of params
        :body: Optional, raw string body
        :returns: a HubrResult

        """

        if params is not None:
            data = urlencode(params)
        elif body is not None:
            data = body
        else:
            data = None

        headers = {
            "Authorization": "token %s" % self._token
        }

        fullUrl = BASE_URL + url
        req = urllib2.Request(fullUrl, data, headers)
        req.get_method = lambda: method # hax to support PUT

        try:
            return HubrResult(self._opener.open(req))
        except urllib2.HTTPError, e:
            if e.getcode() == 401:
                raise e

            return HubrResult(None, e)

class Hubr(object):

    """Main interface for Hubr"""

    def __init__(self, http):
        """Create a new Hubr instance

        :http: an Http instance

        """
        self._http = http
        self._options = {}
        
    def http(self):
        """Get the Http instance for manual calls
        :returns: the Http instance

        """
        return self._http

    def assign(self, issue, userLogin):
        """Assign the given issue number to the given user

        :issue: The issue number
        :userLogin: The user to assign it to
        :returns: a HubrResult

        """

        url = self._repo("issues/%s", issue)
        return self._http.patch(url, json={'assignee': userLogin})

    def get_issue(self, issue):
        return self._http.json(self._repo("issues/%s", issue))

    def get_issues(self, **kwargs):
        """Get a list of issues for the current repo. Accepts
        kwargs to filter the results:

        :state: Either "closed" or "open"
        :labels: List of labels (tags) to require, or a String that's
                 comma-separated
        :milestone: Id or name of a milestone; if a String, we will 
                    automatically query for the id
        :since: A datetime
        :assignee: String user of whom the issue is assigned to; 
                    pass the string "none" for issues assigned to nobody
        :creator: String user of who created the issue
        :returns: A list of issues, or None on error

        """
        params = {}
        for key, val in kwargs.iteritems():
            if val is not None:
                params[key] = val

        if params.has_key('milestone'):
            milestone = params['milestone']
            if type(milestone) != int:
                # make it an int
                params['milestone'] = self.get_milestone_number(milestone)

        if params.has_key('since') and type(params['since']) != str:
            params['since'] = format_date(params['since'])

        if params.has_key('labels') and type(params['labels']) == list:
            params['labels'] = ','.join(params['labels'])

        return self._http.json(self._repo("issues", params))

    def get_milestones(self):
        """Get milestones for the current repo"""
        return self._http.json(self._repo("milestones"))

    def get_milestone_number(self, name):
        """Get the number of a milestone by its name

        :name: @todo
        :returns: @todo

        """
        milestones = self.get_milestones()
        if milestones is None:
            return None

        for milestone in milestones:
            if milestone['title'] == name:
                return milestone['number']

        return None

    def get_user(self, userLogin=None):
        """Fetch the given user, or active user
            if no userLogin is provided
        :userLogin: (optional) if provided, the "login"
                    of the user to fetch
        :returns: a dict with the User, or None on error

        """
        if userLogin is not None:
            return self._http.json('users/%s' % userLogin)

        return self._http.json('user')

    def tag(self, issue, tagName):
        """Add a tag/label to an issue

        :issue: The issue number
        :tagName: The name of the tag/label
        :returns: A HubrResult

        """
        url = self._repo("issues/%s/labels", issue)
        return self._http.post(url, json=[tagName])

    def untag(self, issue, tagName):
        """Remove a tag/label from an issue

        :issue: The issue number
        :tagName: The name of the tag/label
        :returns: A HubrResult

        """
        url = self._repo("issues/%s/labels/%s", issue, tagName)
        return self._http.delete(url)

    def has_option(self, name):
        """Mostly for the vim interface, but will 
        check if the given option has been defined

        :name: The option name. See #get_option
        """
        return self._options.has_key(name.upper())

    def get_option(self, name):
        """Get an option value

        :name: The option name. It is converted to all 
                caps for convenience
        :returns: The value, or None if not set

        """
        name = name.upper()
        if not self._options.has_key(name):
            return None

        return self._options[name]

    def set_option(self, name, value):
        """Manually set an option value

        :name: Option name
        :value: Option value (duh)
        :returns: @todo

        """
        self._options[name] = value

    def _repo(self, url, *args):
        """Return an URL based on the REPO_NAME;
        if we don't have the REPO_NAME option defined,
        this method throws an Exception

        :url: @todo
        :args: Will be interpolated into url, if provided,
                and urlencoded. Alternatively, if a single
                dict is passed, it will be used as get params
        :returns: @todo

        """
        if not self._options.has_key('REPO_NAME'):
            raise Exception("This action requires a REPO_NAME option")

        if len(args):
            # format the args as strings, url-quoted
            if type(args[0]) == dict:
                # get params
                params = urlencode(args[0])
                url = url + '?' + params
            else:
                args = map(str, args)
                args = map(quote_plus, args)
                url = url % tuple(args)
        
        return "repos/%s/%s" % (self._options['REPO_NAME'], url)

    @staticmethod
    def from_config(*configFilePaths):
        """Create a new Hubr from a config file

        :configFilePaths: A var-array of paths to look in.
            Hubr will always look for a .hubrrc in the user's
            home directory, but if any files in the paths
            array exist, their settings will override the defaults,
            in order
        :returns: A new Hubr instance

        """
        userHome = expanduser(DEFAULT_HUBRRC)

        configFilePaths = list(configFilePaths)
        configFilePaths.insert(0, userHome)

        options = {}
        for path in configFilePaths:
            if not isfile(path):
                continue

            with open(path) as fp:
                for line in fp:
                    if line.startswith('#'):
                        continue

                    key, value = line.split('=')
                    commentStart = value.find('#')
                    if commentStart > -1:
                        value = value[:commentStart]
                    value = value.strip()

                    if value[0] == value[-1] == '"':
                        value = value[1:-1]

                    options[key.strip().upper()] = value

        http = Http(options['TOKEN'])
        hubr = Hubr(http)
        hubr._options = options
        return hubr

def main(argv):
    """cli interface to hubr

    :argv: @todo
    :returns: @todo

    """
    hubr = Hubr.from_config()

    import datetime

    # print JSON.dumps(hubr.get_issue(2256), indent=4)
    print JSON.dumps(hubr.get_issues(state='open', milestone="2.10.0"), indent=4)
    # result = hubr.tag(2256, "Not a bug")
    # print result.json()
    # print result.get_status()

if __name__ == '__main__':
    import sys
    main(sys.argv)

