# Process text files

## tr recipes

tr(1) can strip out a range of characters by referring to octal code. (See an ascii -> octal table to determine the proper range.) The notation uses escape slashes as follows:

```bash
tr -d '\013-\031' < input-file
```

Convert alphabet characters to uppercase:

```bash
echo 'It is not nice to shout' | tr '[a-z]' '[A-Z]'
```

## awk recipes

See [GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/html_node/index.html)

```bash
# Print third column of all rows in a comma-delimited file
awk -F',' '{ print $3 }' input-file
# Print last column of all rows in a pipe-delimited file
awk -F'|' '{ print $NF }' input-file
# Print second column of command output (space/tab delimiter implicit)
id | awk '{ print $2 }'
# Print all lines matching regex
awk '/^[Ii]nventory/{ print }' input-file
# Replace regexp instances with string constant
awk '{ gsub(/SSN/,"Note to self") ; print }' input-file
```

## sed recipes

```bash
# Remove all instances of regexp on all lines
sed 's/check bounced//g' input-file
# Convert a comma-delimited file into a pipe-delimited file
sed 's/,/|/g' input-file
# Insert string constant before fourth line of text file 
sed -i '4i Well hello there' input-file
# Insert parameter value before first line of text file
_s='wow, I won!'
sed -i "1i ${_s}" input-file
# Print lines 50 through 100 of text file
sed -n '50,100p ; 100q' input-file
# Replace value on only line 2 of text file
sed '2s/baz/boo/' input-file
# Delete line 91 of a text file
sed '91d' input-file
# Delete all lines containing regexp
sed '/[Oo][Kk]/d' input-file
```

## wc recipes

```bash
# Get length of longest line in a file
wc -L input-file
```

## Convert tabs to blanks (and vice versa)

* expand(1)
* unexpand(1)
