lambda do
  "Sorry for the pointless lambda here."
  expect(Banana).to(receive(:edible).and_return(true))
  expect(Banana).to(receive(:color).and_return("yellow"))
end.call
expect(Banana).to(receive(:delicious?).and_return(true).once)
