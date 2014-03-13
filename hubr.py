#!/usr/bin/env python

from os.path import expanduser
from urllib import urlencode
import urllib2
import json

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
            return json.loads(self._requestResult.read())

        return None


class Hubr(object):

    """Main interface to Hubr"""

    def __init__(self, token):
        """Construct a new Hubr instance

        :token: Github auth token

        """
        self._token = token
        self._options = {}

        self._opener = urllib2.build_opener(urllib2.HTTPSHandler)

    def get(self, url):
        """GET the URL.

        :url: The URL fragment to fetch
        :returns: a HubrResult instance

        """
        return self._request("GET", url)

    def json(self, url):
        """Shortcut to GET the json at URL.

        :url: The URL fragment to fetch
        :returns: a HubrResult instance

        """
        return self.get(url).json()
        
    def _request(self, method, url, params=None):
        """Prepare a request, optionally with params

        :method: GET/POST/PUT
        :url: everything after https://api.github.com/
        :params: Optional, dict of params
        :returns: the result of urlopen()

        """

        if params is not None:
            data = urlencode(params)
        else:
            data = None

        headers = {
            "Authorization": "token %s" % self._token
        }

        req = urllib2.Request(BASE_URL + url, data, headers)
        req.get_method = lambda: method # hax to support PUT

        try:
            return HubrResult(self._opener.open(req))
        except urllib2.HTTPError, e:
            return HubrResult(None, e)

    @staticmethod
    def from_config(configFilePath=None):
        """Create a new Hubr from a config file

        :configFilePath: @todo
        :returns: A new Hubr instance

        """
        if configFilePath is None:
            configFilePath = expanduser(DEFAULT_HUBRRC)

        options = {}
        with open(configFilePath) as fp:
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

                options[key.strip()] = value

        hubr = Hubr(options['TOKEN'])
        hubr._options = options
        return hubr


def main(argv):
    """cli interface to hubr

    :argv: @todo
    :returns: @todo

    """
    hubr = Hubr.from_config()

    print json.dumps(hubr.json("user"), indent=4)

if __name__ == '__main__':
    import sys
    main(sys.argv)
