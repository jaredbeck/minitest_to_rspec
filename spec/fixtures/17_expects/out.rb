lambda do
  "Sorry for the pointless lambda here."
  expect(Banana).to(receive(:edible).and_return(true).once)
  expect(Banana).to(receive(:color).and_return("yellow").once)
end.call
expect(Banana).to(receive(:delicious?).and_return(true).once)
