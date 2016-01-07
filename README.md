# aliasme

A shell script to organize your alias in command line.

## Installation

- download script
```bash
  mkdir ~/.aliasme
  curl https://raw.githubusercontent.com/Jintin/aliasme/master/aliasme.sh > ~/.aliasme/aliasme.sh
```
- add alias to your startup profile (ex: ~/.bash_profile)
```bash
echo "alias al='. ~/.aliasme/aliasme.sh'" >> ~/.bash_profile
```

## Usage

```bash
al add [name] [value]        # add alias with name and value
al rm [name]                 # remove alias by name
al ls                        # alias list
al [name]                    # execute alias associate with [name]
```

## Contributing
Bug reports and pull requests are welcome on GitHub at [https://github.com/Jintin/aliasme](https://github.com/Jintin/aliasme).

## License
The module is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
