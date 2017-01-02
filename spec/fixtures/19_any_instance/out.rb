allow_any_instance_of(Banana).to(receive(:delicious?).and_return(true))
expect_any_instance_of(Kiwi).to(receive(:delicious?).and_return(false))
