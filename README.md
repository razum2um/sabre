# Sabre - Ruby API for Sabre Web Services 

**Sabre** is a ruby implementation of Sabre Travel Network's SOAP Web Services.  It provides a mechanism
for ruby applications to search and book hotels in Sabre's Travel network. 

## Installation

Add it to your Gemfile:

`gem 'sabre'`

Run the following command to install it:

`bundle install`

Run the generator:

`rails generate sabre:install`

This will then create a configuration file named config/initializers/sabre.rb to be modified with
the credentials Sabre provides for subscriber access to each partner.

### The API

With **Sabre** you can access wrapper classes to construct workflows depending on your travel application's needs. 


The syntax looks like this:

```ruby
class User
  include Sabre

  def travel_profile
    session = Session.open
    traveler = Traveler.profile(session, self.first_name, self.last_name, self.phone)
    Session.close
    return traveler # This returns the SOAP response as XML.
  end
end
```

