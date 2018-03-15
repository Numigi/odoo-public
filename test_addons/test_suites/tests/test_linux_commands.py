"""Check that the linux command lines exists in the docker that will be pushed
"""
import subprocess

from odoo.tests import common


class CommandLines(common.TransactionCase):
    """Test suite for command lines."""

    def test_gitoo(self):
        """ gitoo is required"""
        self.assertIsNotNone(subprocess.call(["gitoo", "--version"]))
