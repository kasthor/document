# Document

Manages a Document, the document contains multiple nested objects, but changes on any sub-level is notified to the parent

## Installation

Add this line to your application's Gemfile:

    gem 'document'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install document

## Usage

It mainly iterates from a hash, so any way that's valid for creating a hash should be valid for creating a Document, be aware that if you create a document with a multi-level hash, it will convert any inner hash to a Document in order to privide its main functionality


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
