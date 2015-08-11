#!/usr/bin/python
# -*- coding: utf-8 -*-

# system
import os
import sys
dir = os.path.split(os.path.split(os.path.realpath(__file__))[0])[0]
sys.path.append(os.path.join(dir, 'scripts'))

# testing
import mock
import unittest
from mock import patch

# program
import hdx_register.config as Config


class CheckConfigurationStructure(unittest.TestCase):
  '''Unit tests for the configuration files.'''

  def test_that_load_config_fails_gracefully(self):
    assert Config.FetchConfig('xxx') == False
    assert Config.FetchConfig('dev') != False

  #
  # Testing object types.
  #
  def test_config_is_list(self):
    d = Config.FetchConfig('dev')
    p = Config.FetchConfig('dev')
    assert type(d) is dict
    assert type(p) is dict
