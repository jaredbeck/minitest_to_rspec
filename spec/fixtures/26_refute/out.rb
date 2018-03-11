describe("Banana.delicious!") do
  it("doesn't raise DeliciousError") do
    expect { Banana.delicious! }.to_not(raise_error(DeliciousError))
  end
  it("doesn't raises DeliciousError") do
    expect { Banana.delicious! }.to_not(raise_error(DeliciousError))
  end
  it("doesn't raise namespaced DeliciousError") do
    expect { Banana.delicious! }.to_not(raise_error(Namespace::DeliciousError))
  end
  it("doesn't raises namespaced DeliciousError") do
    expect { Banana.delicious! }.to_not(raise_error(Namespace::DeliciousError))
  end
end
