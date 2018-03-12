describe "Kiwi.delicious!" do
  test "raises Namespace::NotDeliciousError" do
    assert_raises(Namespace::NotDeliciousError) do
      Kiwi.delicious!
    end
  end
end
