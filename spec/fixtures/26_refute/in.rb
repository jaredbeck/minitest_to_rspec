describe "Banana.delicious!" do
  test "doesn't raise DeliciousError" do
    refute_raise(DeliciousError) do
      Banana.delicious!
    end
  end

  test "doesn't raises DeliciousError" do
    refute_raises(DeliciousError) do
      Banana.delicious!
    end
  end

  test "doesn't raise namespaced DeliciousError" do
    refute_raise(Namespace::DeliciousError) do
      Banana.delicious!
    end
  end

  test "doesn't raises namespaced DeliciousError" do
    refute_raises(Namespace::DeliciousError) do
      Banana.delicious!
    end
  end
end
