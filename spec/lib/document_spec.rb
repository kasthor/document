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

  it "merges new values converting the keys to symbols" do
    subject = DocumentHash::Core.new

    subject.merge! "test1" => "value"
    subject.keys.should include :test1

    subject = subject.merge "test2" => "value2"
    subject.keys.should include :test2
  end

  it "receives an after change method" do
    subject = DocumentHash::Core.new
    subject.should respond_to :after_change
  end

  it "triggers the after change block" do
    subject = DocumentHash::Core.new
    test_mock = double("test")
    test_mock.should_receive(:callback_mock).with([:test], "value")

    subject.after_change do |path, value|
      test_mock.callback_mock path, value
    end

    subject["test"] = "value"
  end

  it "receives the right path when multilevel" do
    subject = DocumentHash::Core[ { inner: { attribute: "value" } } ]
    test_mock = double("test")
    test_mock.should_receive(:callback_mock).with([:inner, :attribute], "hello")

    subject.after_change do |path, value|
      test_mock.callback_mock path, value
    end

    subject[:inner][:attribute] = "hello"
  end

  it "triggers a callback before change",focus: true do
    subject = DocumentHash::Core[ { inner: { attribute: "value" } } ]
    test_mock = double("test")
    test_mock.should_receive(:callback_mock).with([:inner, :attribute], "hello")

    subject.before_change do |path, value|
      test_mock.callback_mock path, value
    end

    subject[:inner][:attribute] = "hello"
  end

  it "overrides the value being written by the before_change callback" do
    subject = DocumentHash::Core[ { inner: { attribute: "value" } } ]

    subject.before_change do |path, value|
      "hola"
    end

    subject[:inner][:attribute] = "hello"
    subject[:inner][:attribute].should == "hola"
  end

  it "has a touch functionality that re runs the after change callback" do
    subject = DocumentHash::Core[ { test: :value } ]
    test_mock = double("test")
    test_mock.should_receive(:callback_mock).with( [:test], :value )

    subject.after_change do |path,value|
      test_mock.callback_mock path, value
    end

    subject.touch!
  end

  it "has a touch functionality that handle deeper hashes" do
    subject = DocumentHash::Core[ { inner: { attribute: :value } } ]
    test_mock = double("test")
    test_mock.should_receive(:callback_mock).with( [:inner, :attribute], :value )

    subject.after_change do |path,value|
      test_mock.callback_mock path, value
    end

    subject.touch!
  end

  it "returns a hash" do
    subject = DocumentHash::Core[{ test: "test" }]
    hash = subject.to_hash
    hash.should be_an_instance_of Hash
  end

  it "internal hashes are hashes" do
    subject = DocumentHash::Core[{ test: { inner: "value" } }]
    hash = subject.to_hash
    hash[:test].should be_an_instance_of Hash
  end

  it "return keys stringified as an option" do
    subject = DocumentHash::Core[{ test: "test" }]
    hash = subject.to_hash stringify_keys: true

    hash.keys.all?{ |k| k === String }
  end

  it "return keys symbolized keys as an option" do
    subject = DocumentHash::Core[{ test: "test" }]
    hash = subject.to_hash symbolize_keys: true

    hash.keys.all?{ |k| k === Symbol }
  end

  it "can access values thru methods" do
    subject = DocumentHash::Core[{ test: "value" }]
    subject.test.should == "value"
  end

  it "can access values thru methods at deeper levels" do
    subject = DocumentHash::Core[{ test: { inner: "value" } }]
    subject.test.inner.should == "value"
  end

  it "returns nil for unknown values" do
    subject = DocumentHash::Core[{ test: { inner: "value" } }]
    subject.unknown.should be_nil
  end

  it "returns nil for unknown values at deeper levels" do
    subject = DocumentHash::Core[{ test: { inner: "value" } }]
    subject.unknown.inner.should be_nil
  end

  it "assigns a new value if unknown value is received" do
    subject = DocumentHash::Core[{ test: { inner: "value" } }]
    subject.unknown = 'test'
    subject.unknown.should == 'test'
  end

  it "assigns a new value if unknown value is received at deeper levels" do
    subject = DocumentHash::Core[{ test: { inner: "value" } }]
    subject.unknown.inner = 'test'
    subject.unknown.inner.should == 'test'
  end

  it "can assign values thru methods" do
    subject = DocumentHash::Core[{ test: "value" }]
    subject.test = "new"
    subject.test.should == "new"
  end

  it "can assign values thru methods at deeper levels" do
    subject = DocumentHash::Core[{ test: { inner: "value" } }]
    subject.test.inner = "new"
    subject.test.inner.should == "new"
  end

end
