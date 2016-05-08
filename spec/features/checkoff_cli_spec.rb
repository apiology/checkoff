require 'spec_helper'

describe 'checkoff' do
  it 'starts up with no arguments' do
    expect(exec_io('checkoff'))
      .to eq("USAGE: checkoff\n")
  end

  # ['simple', 'complex_1', 'complex_2', 'complex_3',
  #  'complex_4', 'complex_5', 'extra'].each do |type|
  #   it "handles #{type} case", wip: false do
  #     expect(exec_io "cat spec/samples/#{type}_moves.txt | " +
  #            "chess spec/samples/#{type}_board.txt")
  #     .to eq(IO.read("spec/samples/#{type}_results.txt"))
  #   end
  # end
end
