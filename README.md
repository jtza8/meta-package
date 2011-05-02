## About

Meta-Package is a packaging assistant. For the moment, it automates
the process of exporting symbols from a package.

## Usage

It's recommended that you consider importing two symbols from this
package. The first is INTERNAL and the second is AUTO-EXPORT.

Use the INTERNAL macro to specify symbols as being internal, as
apposed to being external. :P

    (internal foo bar baz) ; Prevents these symbols from being exported.

Finally, in the last lisp file to be loaded, use AUTO-EXPORT to
automatically export all symbols not deemed internal as above.

## Dependencies

Mandatory:
* None

Optional:
* XLUnit (for unit tests)

## Installation

### On Unix-like Systems

Extract the source to the desired directory. Then, while in the
appropriate ASDF systems directory execute the following command,
where `../path/to/resource-tree` is obviously replaced as suitable:

    find ../path/to/resource-tree -name '*.asd' -exec ln -s '{}' \;