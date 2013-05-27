describe DocumentHash::Core do
  it "inherits from a hash" do
    subject.is_a? Hash
  end

  it "knows when a key has changed" do
    subject[:test] = :test

    subject.should be_changed
  end

  it "enumerates the changed keys" do
    subject[:test] = :test

    subject.should include :test
  end

  it "matches string keys to symbols" do
    subject[:test] = "test"

    subject["test"].should == "test"
  end

  it "converts any internal hashes to DocumentHashes" do
    subject[:test] = { inner: "test" }

    subject[:test].should be_a_kind_of DocumentHash::Core
  end

  it "makes it child documents to refer its parent" do
    subject[:test] = { inner: "test" }

    subject[:test].__send__(:parent).should == subject
    subject[:test].__send__(:parent_key).should == :test
  end

  it "notifies its parent when a change ocurr" do
    subject[:test] = { inner: "test" }
    subject.__send__(:changed_attributes).should_receive(:<<).with(:test)
    subject[:test][:inner] = "modified"
  end

  it "reset its changed status" do
    subject[:test] = "xxx"
    expect{
      subject.reset!
    }.to change(subject, :changed?).from(true).to(false)
  end

  it "has a changed status if a child changed" do
    subject[:test] = { inner: "test" }
    subject.reset!
    expect{
      subject[:test][:inner] = "modified"
    }.to change(subject, :changed?).from(false).to(true)
  end

  it "resets child changed status when reseting the root" do
    subject[:test] = { inner: "test" }
    subject[:test][:inner] = "modified"
    subject.reset!

    subject[:test].should_not be_changed
  end

  it "converts inner hashes into DocumentHashes" do
    subject = DocumentHash::Core[ { test: { inner: "test" } } ]

    subject[:test].should be_a_kind_of DocumentHash::Core
  end

  it "simbolizes the keys when creating a hash" do
    subject = DocumentHash::Core[ { "test" => "value" } ]
    subject.keys.should include :test
  end
end
