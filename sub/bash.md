# Bash tips

## Variables and pipelines

### Complaining about unset variable expansion

This feature will cause `bash(1)` to throw an error message if any attempt is made to expand an unset variable.

```bash
set -u
```

Using this (very wise) option will require a change to null parameter tests:

```bash
[ -z "${_dunno}" ]  # This will cause script to error out

[ "x" == "${_dunno:-x}" ]  # True means parameter was null (unset)
```

### Exiting with non-zero status if any pipeline part fails

This feature will cause `bash(1)` to assign a non-zero exit code to `$?` if any command within the pipeline fails. If this feature isn't turned on (it isn't by default), then `$?` contains the exit code from the last command in the pipeline.

```bash
set -o pipefail
```

### Test whether a variable is set

```bash
# If $_name is null/unset, a message is printed to stderr (and the shell exits)
${_name:?}
```

### Expand to a default value if variable unset

```bash
# If $_age is set, the value of $_age is printed;
# If $_age is unset, 100 is printed
echo ${_age:-100}
```

### Setting a variable as read-only

```bash
# This will prevent $_flavor from being reassigned later
# with a different value.
readonly _flavor='banana-grape'
```

### Giving local scope to a variable

```bash
# This declaration works within functions, and makes the
# variable scoped to just within that function
myfun() {

        local _test="$(grep meme /etc/passwd)"

}
```

### Print a variable's length

```bash
# Prints the length in bytes of the value in _city
echo ${#_city}
```

### Useful internal variables

| `$0` | Script name |
| `$#` | Number of arguments |
| `"$@"` | All argument values, each quoted |
| `$?` | Command exit status (or function return status) |
| `$$` | PID of executing script |
| `$UID` | UID of user executing script (`$EUID` is used to determine "effective UID") |
| `$LINENO` | Line of script currently executing |
| `$HOSTNAME` | Current hostname |
| `$RANDOM` | Random integer between 0 and 32767 |

## Shell Globbing

The following characters, when used non-quoted and non-escaped (`\` to escape) expand to special patterns.

| `*` | Match any string of any length |
| `?` | Match any single character |
| `[abc]` | Match any one of a, b, or c |

## String Manipulation

### String case conversion

| `${variable^^}` | All upper-case of string in variable |
| `${variable,,}` | All lower-case of string in variable |

```bash
_brand='Gamestop'

echo "In all uppercase, now: ${_brand^^}"
```

### Extract a substring

There are a couple forms of this expansion, and positive or negative numbers can be used, depending on desired behavior.

| `${variable: offset}` | Extract substring of variable, starting from `offset` |
| `${variable: offset: length}` | Extract substring of variable, `length` chars, starting from `offset` |

The string `offset` is zero-based. (So the first character is `0`.)

```bash
_boop="Hello there, lady"

# This prints 'ere, lady'
echo ${_boop: 8}

# This prints 'Hello t'
echo ${_boop: 0: 7}

# This (negative offset) prints 'lady'
echo ${_boop: -4}
```

### String trimming

`bash(1)` has features for trimming the beginning of a string or the end of a string, based on pattern matches. Additionally, non-greedy or greedy matching can be specified.

| `${variable#pattern}` | Remove `pattern` from beginning of string (non-greedy) |
| `${variable##pattern}` | Remove `pattern` from beginning of string (greedy) |
| `${variable%pattern}` | Remove `pattern` from end of string (non-greedy) |
| `${variable%%pattern}` | Remove `pattern` from end of string (greedy) |

Example of greedy vs. non-greedy matching:

```bash
_quote='No fate but what we make for ourselves'

# Will print "e but what we make for ourselves"
# (i.e. the match stops at the first 't')
echo ${_quote#*t}

# Will print "we make for ourselves"
# (i.e. the match goes for the last possible 't'
# in the string)
echo ${_quote##*t}
```

### String match and replace

There are a variety of invocations for matching a pattern (using characters and shell globs) and replacing. In each case, the value of `variable` is expanded and then operated on based on the `pattern` and any modifiers.

| `${variable/pattern/newstring}` | Replace first instance of `pattern` with `newstring` |
| `${variable//pattern/newstring}` | `//` modifier means replace all instances |
| `${variable/#pattern/newstring}` | `#` modifier means only match start of string in variable |
| `${variable/%pattern/newstring}` | `%` modifier means only match end of string in variable |
| `${variable/pattern/}` | Delete first instance of `pattern` |
| `${variable//pattern/}` | Delete all instances of `pattern` |

Example that also incorporates a glob:

```bash
_wisdom='Some cause happiness wherever they go; others whenever they go'

# Prints "Some cause ; others react"
echo ${_wisdom/%hap*/; others react}
```

## Test operators

`bash(1)` can logically evaluate variable values (within braces, or using the `test` builtin) for various qualities.

### String test operators

| `string1 == string2` | True if strings are equal (POSIX calls for use of `=` as the test operator in this case.) |
| `string1 != string2` | True if strings are not equal |
| `-z string` | True if length of string is zero |
| `-n string` | True if length of string is greater than zero |

### Numeric test operators

| `num1 -eq [-ne] num2` | True if numbers are equal [or not equal] |
| `num1 -gt [-ge] num2` | True if num1 is greater than [or greater than/equal to] num2 |
| `num1 -lt [-le] num2` | True if num1 is less than [or less than/equal to] num2 |

### File test operators

`bash(1)` can test files (within braces, or using the `test` builtin) for various qualities. The following is a small subset of test options available.

All file tests are conducted using the permissions of the effective user. This means test results may differ, depending on who is running the script or interactive shell.

| `-e file` | True if file exists |
| `-r file` | True if file exists, and is readable |
| `-w file` | True if file exists, and is writeable |
| `-x file` | True if file exists, and is executable |
| `-s file` | True if file exists, and has a size greater than zero |
| `-f file` | True if file exists, and is a regular file |
| `-d file` | True if file exists, and is a directory |

## here-documents and here-strings

The `bash(1)` environment includes a couple interesting features to allow more natural processing of both long lines of input data and command output.

### here-document

The `here-document` feature provides to the stdin of a program a delimited, multi-line input. It uses the `<<` operator to specify delimiters; everything between those is input text.

For instance:

```bash
cat <<EOF
Hello there, guv.
Quite nice to see you today!
Don't forget your knickers.
EOF
```

Upon execution, that will print the three lines of input, but not the 'EOF' delimeter. (And 'EOF' is arbitrary. Most any word can be used as a delimeter.)

Write to a file:

The `tee(1)` command (though noisy) provides a concise way to build an output file.

```bash
tee /etc/cron.d/my-cronjob <<MYEOF
# This is not especially useful
45 3 * * * someguy /bin/true
MYEOF
```

Prettier code formatting:

For better code alignment, using the `<<-` operator will tell a `here-document` to ignore leading tabs prior to the input text. (Note that these *have* to be hard tabs, not spaces, or it won't work.)

```bash
cat <<-MYEOF
    Hello there, guv.
    Quite nice to see you today!
MYEOF
```

### here-string

As for the `here-string` feature, it allows a simple way to assign command output (as one example) to the stdin of a program. It uses the `<<<` operator to do so.

For instance:

```bash
cat <<<"$(mount -l)"
```

Upon execution, the `mount(8)` command will be run, and its quoted (to preserve newline characters) output will be fed as stdin to `cat(1)`.

Variable expansion example:

```bash
cat <<<"${_first_name}"
```

## Operating on files in a directory

Source: [Bash Pitfalls](http://mywiki.wooledge.org/BashPitfalls)

What follows is the correct way to deal with looping over files in a directory. Notice the existence test, and the importance of quoting.

```bash
for _i in *q* ; do
        # If no files are found, $_i (quoted) will actually contain
        # the string '*q*', so we test here to get out.
        if [ ! -e "${_i}" ] ; then
                break
        fi

        file "${_i}"
done
```

## Looping line-by-line through a text file

Correctly reading lines from a file is as follows - documented on this [StackOverflow thread](http://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable).

```bash
while IFS='' read -r _line || [ -n "${_line}" ] ; do
        # IFS='' prevents truncation of leading or trailing space.
        # -r prevents backslash interpretation
        # the [ -n $file ] test avoids missing the last line if no '\n'
        echo "Line data: ${_line}"
done < input.txt
```

## Signal handling and cleanup

For any scripts using `mktemp(1)` (or other temporary file creation), it's a good idea to handle cleanup using the bash builtin "trap".

```bash
trap 'cleanup' EXIT
trap 'exit 2' HUP INT QUIT TERM

function cleanup() {
        rm -f /tmp/some-tmp-file
}

sleep 60
```

In this example, the `cleanup()` function will **always** run when the script exits (whether it catches a signal or not). The `exit 2` code will only run when the script is killed by one of the named signals.

References:
* https://mywiki.wooledge.org/SignalTrap
* https://stackoverflow.com/questions/8122779/is-it-necessary-to-specify-traps-other-than-exit
