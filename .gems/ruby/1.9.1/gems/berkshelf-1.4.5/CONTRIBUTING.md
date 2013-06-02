# Contributing

## Developing

If you'd like to submit a patch:

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add [tests](#testing) for it. This is important so that it isn't broken in a
   future version unintentionally.
4. Commit. **Do not touch any unrelated code, such as the gemspec or version.**
   If you must change unrelated code, do it in a commit by itself, so that it
   can be ignored.
5. Send a pull request.

## Testing

### Install prerequisites

Install the latest version of [Bundler](http://gembundler.com)

    $ gem install bundler

Clone the project

    $ git clone git://github.com/RiotGames/berkshelf.git

and run:

    $ cd berkshelf
    $ bundle install

Bundler will install all gems and their dependencies required for testing and developing.

### Running unit (RSpec) and acceptance (Cucumber) tests

Simply copy the `spec/knife.rb.sample` to `spec/knife.rb`, and point it at a
chef server. Berkshelf tests may upload and destroy cookbooks on your chef
server, so be sure to configure a server safe for this task.

    $ bundle exec guard start

See [here](https://github.com/tdegrunt/vagrant-chef-server-bootstrap) for a
quick way to get a testing chef server up.

### Debugging Issues
By default, Berkshelf will only give you the top-level output from a failed command. If you're working deep inside the core, an error like:

    Berkshelf Error: wrong number of arguments (2 for 1)

isn't exactly helpful...

Specify the `BERKSHELF_DEBUG` flag when running your command to see a full stack trace and other helpful debugging information.
