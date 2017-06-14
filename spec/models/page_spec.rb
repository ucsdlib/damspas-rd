require 'spec_helper'

describe Page do
  subject { described_class.new }

  it "has a slug" do
    subject.slug = "foo"
    expect(subject.slug).to eq("foo")
  end

  it "has a title" do
    subject.title = "Foo Page"
    expect(subject.title).to eq("Foo Page")
  end

  it "has a body" do
    subject.body = "<p>Some markup.</p>"
    expect(subject.body).to eq("<p>Some markup.</p>")
  end
end
