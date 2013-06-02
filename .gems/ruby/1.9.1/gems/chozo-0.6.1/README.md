# Chozo
[![Build Status](https://secure.travis-ci.org/reset/chozo.png?branch=master)](http://travis-ci.org/reset/chozo)
[![Dependency Status](https://gemnasium.com/reset/chozo.png?travis)](https://gemnasium.com/reset/chozo)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/reset/chozo)

A collection of supporting libraries and Ruby core extensions

## Installation

    $ gem install chozo

## Usage

Include all of Chozo into your application

    require 'chozo'

Or maybe just a piece?

    require 'chozo/config'

### JSON Config

    require 'chozo/config'

    module MyApp
      class Config
        include Chozo::Config::JSON
      end
    end

# Authors and Contributors

* Jamie Winsor (<jamie@vialstudios.com>)
