describe "Kiwi.delicious!" do
  test "raises NotDeliciousError" do
    assert_raises(NotDeliciousError) do
      Kiwi.delicious!
    end
  end
end
