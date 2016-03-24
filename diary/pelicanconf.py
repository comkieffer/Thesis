#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Tibo'
SITENAME = u'Thesis Log'
SITEURL = ''

THEME='aboutwilson'

PLUGIN_PATHS = ['./plugins']
PLUGINS = ['render_math']

SUMMARY_MAX_LENGTH = 100

PATH = 'content/'
STATIC_PATHS = ['static/']
EXTRA_PATH_METADATA = {
    'static/robots.txt': {'path': 'robots.txt'},
    'static/favicon.ico': {'path': 'favicon.ico'},
}

# Pelican can be really smart/dumb with regards to html files. It tries to interpret them as normal 
# pages/articles but this can be counter productive if you just want some html file to hang around 
# in the static directory since they will be missing the required meta tags. 
READERS = {'html': None}


TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = u'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = ()

# Social widget
SOCIAL = ()

DEFAULT_PAGINATION = False

