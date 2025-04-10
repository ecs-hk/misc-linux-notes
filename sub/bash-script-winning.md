# Bash scripting like a serious person

Scripting with bash can appear to be simple, but in reality there are many ways to introduce logical errors that are difficult to detect. What follows is an opinionated approach to reducing the probability of writing buggy, dangerous scripts.

## The what

* [Example opinionated bash script](./bin/example-script.bash)

### Usage

```bash
./example-script.bash 
Usage: example-script.bash -n NAME -x joke|fortune [-d]
```

```bash
./example-script.bash -n Erik -x joke
Hello, Erik. Some words of wisdom to consider..

 ___________________________________
/ Chuck Norris doesn't use keys, he \
\ always kicks the door in.         /
 -----------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

## The why

### Shell options

```bash
set -u
```

Protects against undefined variables being referenced.

```bash
set -o pipefail
```

Causes a failure of any part of a pipeline to exit with a nonzero code. By default, if the last part of a pipeline exits with zero, the entire pipeline exit code is zero.

### Variable definitions

```bash
readonly _output_d="$(mktemp -d -p /tmp ${0##*/}.XXXXXX)"
readonly _log="${_output_d}/log.txt"
```

Sets variable to read-only (i.e. prevents value from being overwritten). Naming convention of `_foo` helps to avoid collisions with environment variable names (which are often uppercase) and CLI programs (which rarely begin with an underscore).

### Helper functions

```bash
errout() {
        readonly _err_msg="${0##*/} error: ${1} (see ${_log})"
        printf '%s\n' "${_err_msg}" >&2
        exit 1
}
```

Can be called to handle error situations consistently. This approach helps avoid having dozens of `exit` statements littering a script.

## Signal handling

```bash
trap 'cleanup' EXIT
```

When script completes, `cleanup()` function will always be called.

```bash
trap 'exit 2' HUP INT QUIT TERM
```

Sets a specific exit code if script is killed. Most useful for long running batch scripts.
