Banana.any_instance.stubs(:delicious?).returns(true)
Kiwi.any_instance.expects(:delicious?).returns(false)
