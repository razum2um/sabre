# Sabre - Ruby API for Sabre Web Services 

**Sabre** is a ruby wrapper for Sabre Web Services SOAP/XML.  

aims to be as flexible as possible while helping you with powerful components to create
your forms. The basic goal of SimpleForm is to not touch your way of defining the layout, letting
you find the better design for your eyes. Most of the DSL was inherited from Formtastic,
which we are thankful for and should make you feel right at home.

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
  include Sabre

  def user_profile
    session = Session.open
    traveler = Traveler.profile(session, first_name, last_name, phone)
    Session.close
  end
end
```

