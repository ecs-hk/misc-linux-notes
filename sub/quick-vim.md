# Quick vim tips

## Navigation mode

Tip: hit `Esc` to enter navigation mode

### Line navigation

| Keystroke           | Action |
| ------------------- | ------ |
| `w`, `b`            | hop forward, backward one word |
| `)`, `(`            | hop to next, previous sentence |
| `0`, `$`            | hop to beginning, end of current sentence |

### Screen navigation

| Keystroke           | Action |
| ------------------- | ------ |
| `H`, `M`, `L`       | position to top, middle, bottom of screen |
| `Ctrl-f`            | scroll forward to next page |
| `Ctrl-b`            | scroll back to previous page |

### File navigation

| Keystroke           | Action |
| ------------------- | ------ |
| `1G`                | jump to first line in file |
| `35G`               | jump to 35th line in file |
| `G`                 | jump to last line in file |

### Undo

| Keystroke           | Action |
| ------------------- | ------ |
| vim: `u`            | undo, keep pressing for more undo |
| vim: `Ctrl-r`       | redo, keep pressing for more redo |
| nvi: `u`, `.`       | undo, press `.` for more undo, or `u` to switch |
| nvi: `u`, `.`       | redo, press `.` for more redo, or `u` to switch |

### Search and replace

| Keystroke           | Action |
| ------------------- | ------ |
| `/pattern`          | search forward for pattern |
| `?pattern`          | search backward for pattern |
| `n`, `N`            | repeat previous search forward, backward |
| `:%s/boo/baz/g`     | search entire file for boo, replace with baz |
| `:%s/boo/baz/gc`    | same as above, but prompt before each replace |

******

## Edit mode

Tip: entering any of these keystrokes puts you into edit mode

### Insert command

| Keystroke           | Action |
| ------------------- | ------ |
| `i`, `a`            | insert text before, after cursor |
| `I`, `A`            | insert text at start, end of line |
| `O`, `o`            | begin new line above, below cursor |

### Change command

| Keystroke           | Action |
| ------------------- | ------ |
| `R`                 | replace characters (until change to navigation mode) |
| `cw`                | change/replace word |
| `cc`                | change/replace line |
| `J`                 | join current line and next line |

### Delete command

| Keystroke           | Action |
| ------------------- | ------ |
| `x`, `X`            | delete character under, before cursor |
| `dw`                | delete word |
| `dd`                | delete line |
| `8dd`               | delete 8 lines |
| `D`                 | delete from cursor to end of line |

### Copy/paste command

| Keystroke           | Action |
| ------------------- | ------ |
| `yw`                | yank (copy) word |
| `yy`                | yank line |
| `yG`                | yank from cursor until end of file |
| `ma` then `y'a`     | mark "buffer a", then copy from "buffer a" to cursor position |
| `p`, `P`            | paste yanked text after, before cursor |

******

## Visual mode

### Entering visual mode

| Keystroke             | Action |
| -------------------   | ------ |
| `v`                   | character-wise visual mode |
| `V`                   | line-wise visual mode |
| `Ctrl-v`              | block-wise visual mode |

### Indentation recipe

Given the yaml:

```yaml
---
this:
  is:
    an:
      - indented
      - yaml
      - example
```

Move cursor to "this:" and hit `Vjjjjj3>`

Explanation:
* `V` - enter line-wise visual mode
* `jjjjj` - select the next five lines
* `3>` - move all selected lines three indentations to the right
