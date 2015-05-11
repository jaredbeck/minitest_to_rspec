a.stubs(:b).returns(1).once
a.stubs(:c).returns(2).twice
a.expects(:d).once
a.expects(:e).twice
a.expects(:f).returns(3).once
a.expects(:g).returns(4).twice
