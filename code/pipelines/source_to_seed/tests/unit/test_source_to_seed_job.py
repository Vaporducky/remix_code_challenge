from unittest import TestCase
from unittest.mock import patch, MagicMock, ANY

from parameterized import parameterized

import src.source_to_seed_job as job


class TestSourceToSeedJob(TestCase):
    @classmethod
    def setUpClass(cls):
        pass

    @parameterized.expand([
        ("plural_orders", "orders", "order"),
        ("plural_customers", "customers", "customer"),
        ("singular_order", "order", "order"),
        ("no_trailing_s", "data", "data"),
        ("empty_string", "", ""),
        ("only_s", "s", ""),
        ("single_non_s", "x", "x"),
        ("capital_s", "Users", "User"),
        ("uppercase_s", "S", "S")
    ])
    def test_normalize_entity(self, _, input_value, expected):
        result = job.SourceToSeedJob._normalize_entity(input_value)
        self.assertEqual(result, expected)
