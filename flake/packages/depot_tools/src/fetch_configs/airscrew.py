import sys

import config_util  # pylint: disable=import-error


# This class doesn't need an __init__ method, so we disable the warning
# pylint: disable=no-init
class Airscrew(config_util.Config):
    """Basic Config class for the Airscrew repository."""
    @staticmethod
    def fetch_spec(_props):
        solution = {
            'name': 'src/flutter',
            'url': 'git@github.com:razorrock/airscrew.git',
            'custom_deps': {
                'src': 'ssh://git@github.com/razorrock/buildroot.git',
                'src/flutter/third_party/libdeflate': 'https://github.com/ebiggers/libdeflate.git',
                'src/flutter/third_party/ncurses': 'https://github.com/ThomasDickey/ncurses-snapshots.git@v6_5',
                'src/flutter/third_party/notcurses': 'ssh://git@github.com/razorrock/notcurses.git',
            },
        }
        spec = {'solutions': [solution]}
        return {
            'type': 'gclient_git',
            'gclient_git_spec': spec,
        }

    @staticmethod
    def expected_root(_props):
        return 'src'


def main(argv=None):
    return Airscrew().handle_args(argv)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
