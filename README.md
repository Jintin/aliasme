# aliasme
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/dc29953069bf43438f4abac2629e4b5a)](https://app.codacy.com/gh/Jintin/aliasme/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![CI](https://github.com/Jintin/aliasme/actions/workflows/ci.yml/badge.svg)](https://github.com/Jintin/aliasme/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/alebcay/awesome-shell)

A shell script to organize your alias in command line.

## Installation

### Homebrew (Recommended)

```bash
brew tap Jintin/homebrew-tap
brew install aliasme
```

Then add the following line to your shell profile (e.g., `~/.bash_profile` or `~/.zshrc`):

```bash
source $(brew --prefix)/opt/aliasme/libexec/aliasme.sh
```

### Manual

- download script
```bash
  mkdir ~/.aliasme
  curl https://raw.githubusercontent.com/Jintin/aliasme/master/aliasme.sh > ~/.aliasme/aliasme.sh
```
- add alias to your startup script (ex: ~/.bash_profile, ~/.bashrc)
```bash
echo "source ~/.aliasme/aliasme.sh" >> ~/.bash_profile
```

## Usage
```bash
$ al add [name] [command]      # add alias command with name
$ al rm [name]                 # remove alias by name
$ al ls                        # list all alias
$ al [name]                    # execute alias associate with [name]
$ al -v                        # version information
$ al -h                        # help
```

## Contributing
Bug reports and pull requests are welcome on GitHub at [https://github.com/Jintin/aliasme](https://github.com/Jintin/aliasme).

## License
The module is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
