# WithCred

Put your credentials in a standard convenient place. This place is
1) An encrypted tarball, which could decrypt on deploy. If you like, you
can commit them into your SCM/VCS, but this is not recommended.
2) A series of unencrypted YAML files. Like above, but you can't commit
them into your SCM/VCS
3) An encrypted environment variable and a password. This gem helps you
encrypt your credentials on deployment with capistrano and run commands
with the credentials as environment variables.

## Installation

Add this line to your application's Gemfile:

    gem 'with_cred'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install with_cred

## Usage

(1) Add the directory credentials/ and credentials.* to your .gitignore
(2) Put your facebook credentials as follows in
credentials/production/facebook.yaml
api_token: "DEADBEEF543254738o25y437"
api_secret: "FEEBDAED3215432543523452"
(3) Add `config.credentials_mode = "production"` to your config/environments/production.rb
(4) Access from ruby
```ruby
WithCred.entials(:facebook) do |credentials|
  #Set up the facebook API stuff
end

The credentials_mode is independent from Rails.env. If you want your
credentials to be available to all credentials_mode s, then you should
put your yaml in credentials/
```

Tasks
```
# Decrypt, asking for password
rake credentials:decrypt

# Decrypt, Looking in the file /etc/yourapp/.secret for the password
rake credentials:decrypt[/etc/yourapp/.secret]

# Encrypt, asking for the password
rake credentials:encrypt

# Encrypt, Looking in the file /etc/yourapp/.secret for the password
rake credentials:encrypt[/etc/yourapp/.secret]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
