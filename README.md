# Sabre - Ruby API for Sabre Web Services 

**Sabre** is a ruby wrapper for Sabre Web Services SOAP/XML.  It aims to provide a ruby-like
way of searching and booking hotels in Sabre's Travel network. 

## Installation

Add it to your Gemfile:

`gem 'sabre'`

Run the following command to install it:

`bundle install`

Run the generator:

`rails generate sabre:install`

## Configuration

**Sabre** has several configuration options. You can read and change them in the initializer
created by **Sabre**, so if you haven't executed the command below yet, please do:

`rails generate sabre:install`

### The API

With **Sabre** you can configure how your components will be rendered using the wrappers API.
The syntax looks like this:

```ruby
class User
  include Sabre

  def travel_profile
    session = Session.open
    traveler = Traveler.profile(session, self.first_name, self.last_name, self.phone)
    Session.close
  end
end
```

