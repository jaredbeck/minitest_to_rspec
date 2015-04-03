Code Style
==========

The code style is whatever [ruby2ruby][6] feels like printing,
and is not configurable.  The goal is not style, but to get to
rspec quickly.

To clean up the style a bit afterwards, here are some tips.

1. Remove parenthesis around `describe` and `it` arguments.

```
Find: (describe|it)\((['"])(.*)['"]\) do
Replace: $1 $2$3$2 do
```
