
from odoo.tests import common


class TestSpecificOdooRCFile(common.TransactionCase):

    def test_database_name_matches_name_in_specific_odoo_rc_file(self):
        """Test that the database name the one from the specific rc file given to Odoo.

        The specific rc file location is given by the environment variable SPECIFIC_ODOO_RC.
        This variable is passed through the docker-compose.yml.
        """
        self.assertEqual(self.env.cr.dbname, 'odoo-specific')
