Supported Assertions
====================

A quick survey of one mid-sized test suite (14 kilolines) found
the following assertions in use.

```
625 assert
530 assert_equal
84 assert_difference
38 assert_no_difference
10 refute
10 assert_nil
5 assert_nothing_raised
4 assert_match
2 assert_raises
1 refute_equal
0 refute_same
0 refute_respond_to
0 refute_predicate
0 refute_operator
0 refute_nil
0 refute_match
0 refute_kind_of
0 refute_instance_of
0 refute_includes
0 refute_in_epsilon
0 refute_in_delta
0 refute_empty
0 assert_throws
0 assert_silent
0 assert_send
0 assert_same
0 assert_respond_to
0 assert_present
0 assert_predicate
0 assert_output
0 assert_operator
0 assert_not
0 assert_kind_of
0 assert_instance_of
0 assert_includes
0 assert_in_epsilon
0 assert_in_delta
0 assert_empty
0 assert_blank
```

Assertions which are not used in the targeted test suite
are not yet supported, but contributions are welcome.

A Script to Count Assertions
----------------------------

```bash
find test -type f -name '*.rb' | xargs cat > all_tests;
for a in $( cat ~/Desktop/assertions ); do
  echo -n $a
  ggrep -E "\\b$a\\b" all_tests | wc -l
done |
awk '{print $2 " " $1}' |
sort -nr
```
