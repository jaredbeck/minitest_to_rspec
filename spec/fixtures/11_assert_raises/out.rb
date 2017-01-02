describe("Kiwi.delicious!") do
  it("raises NotDeliciousError") do
    expect { Kiwi.delicious! }.to(raise_error(NotDeliciousError))
  end
end