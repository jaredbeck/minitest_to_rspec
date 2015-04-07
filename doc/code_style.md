Code Style
==========

The code style is whatever [ruby2ruby][1] feels like printing,
and is not configurable.  The goal is not style, but to get to
rspec quickly.

To clean up the style a bit afterwards, here are some tips.

1. Remove parenthesis around `describe` and `it` arguments.

```
Find: (context|describe|it)\((['"])(.*)['"]\) do
Replace: $1 $2$3$2 do
```

1. Convert `be_truthy` to [predicate matchers][2].

```
Find: expect\((.*).valid\?\)\.to\(be_truthy\)
Replace: expect($1).to be_valid
```

And the negated variant:

```
Find: expect\(\(not (.*).valid\?\)\)\.to\(be_truthy\)
Replace: expect($1).to be_invalid
```

[1]: https://github.com/seattlerb/ruby2ruby
[2]: https://relishapp.com/rspec/rspec-expectations/v/3-2/docs/built-in-matchers/predicate-matchers
