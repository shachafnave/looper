# Loop plan: greet

| Loop | Agent | Output | Gate |
| --- | --- | --- | --- |
| 1 | general-purpose | test_greet.py | command |
| 2 | general-purpose | greet.py | review |

## Evidence

- Loop 1: `python3 -m unittest` failed as expected.
- Loop 2: written by general-purpose, gate pending.
