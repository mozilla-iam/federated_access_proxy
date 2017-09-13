# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Contributors: Andrew Krug <akrug@mozilla.com>

"""Configuration loader for different environments."""

import os
import watchtower
import logging

from utils import get_secret

class Config(object):
    def __init__(self, app):
        self.app = app
        self.environment = os.environ.get('ENVIRONMENT')
        self.settings = self._init_env()

    def _init_env(self):
        if self.environment == 'Production':
            self.app.logger.addHandler(watchtower.CloudWatchLogHandler())
            return ProductionConfig()
        elif self.environment == 'Staging':
            self.app.logger.addHandler(watchtower.CloudWatchLogHandler())
            return StagingConfig()
        else:
            return DevelopmentConfig()


class DefaultConfig(object):
    """Defaults for the configuration objects."""
    DEBUG = True
    LOG_LEVEL = logging.DEBUG
    PERMANENT_SESSION = True
    PERMANENT_SESSION_LIFETIME = 86400
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SECURE = True

    SECRET_KEY = get_secret('accessproxy.flask_secret', {'app': 'accessproxy'})
    REVERSE_PROXY_COOKIE_NAME = 'session'
    SESSION_TYPE = 'filesystem'
    SESSION_FILE_THRESHOLD = 5000
    SESSION_FILE_DIR = '/tmp/accessproxy/sessions/'
    SESSION_FILE_MODE = 0o600

class ProductionConfig(DefaultConfig):
    LOG_LEVEL = logging.INFO
    DEBUG = False

class StagingConfig(DefaultConfig):
    LOG_LEVEL = logging.DEBUG
    DEBUG = False

class DevelopmentConfig(DefaultConfig):
    DEVELOPMENT = True
    DEBUG = True
    SECRET_KEY = 'abab123123'
