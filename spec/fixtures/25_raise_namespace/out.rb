describe("Kiwi.delicious!") do
  it("raises Namespace::NotDeliciousError") do
    expect { Kiwi.delicious! }.to(raise_error(Namespace::NotDeliciousError))
  end
end
