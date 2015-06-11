Code Style
==========

The code style is mostly determined by [sexp2ruby][1],
and is not configurable yet.

To clean up the style a bit afterwards, here are some tips.

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

[1]: https://github.com/jaredbeck/sexp2ruby
[2]: https://relishapp.com/rspec/rspec-expectations/v/3-2/docs/built-in-matchers/predicate-matchers
