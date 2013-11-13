describe DocumentHash::Nil do
  it "is false" do
    subject.should == false
  end

  it "is null" do
    subject.should be_nil
  end
end
