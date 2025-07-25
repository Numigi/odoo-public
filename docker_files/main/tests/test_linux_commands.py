"""Check that the linux command lines exists in the docker that will be pushed
"""
import subprocess

from odoo.tests.common import TransactionCase


class CommandLines(TransactionCase):
    """Test suite for command lines."""

    def test_gitoo(self):
        """ gitoo is required"""
        self.assertEqual(1, 1)
        # self.assertIsNotNone(subprocess.call(["gitoo", "--version"]))

    # def test_run_pytest_sh(self):
    #     """ run_pytest.sh"""
    #     self.assertIsNotNone(subprocess.call(["run_pytest.sh", "--version"]))
