
<p align="center">
  <a href="https://rubyonrails.org/"><img width="300" src="https://zakaria.dev/assets/images/rails_base_app/Ruby_On_Rails_Logo.png" alt="Ruby On Rails"></a>

# Rails API session auth template
This Rails 7 API-only app is intended as a template to kick-start projects.

[![](https://badgen.net/badge/Rails/7.0.3.1/red)](https://github.com/JHarrison89/rails-api-session-auth-template/blob/main/Gemfile.lock)
[![](https://badgen.net/badge/Ruby/3.0.0/orange)](https://github.com/JHarrison89/rails-api-session-auth-template/blob/main/Gemfile.lock)

The app includes...

- stateless session authentication 
- CSRF protection
- REST endpoints for 
- - sign up 
- - sign in 
- - sign out 
- - forgot password 
- - reset password 
- - event (Dummy resource for demo purposes)
- Action mail 
- - sends a sign-up email 
- - sends a password reset email


## Setup
- Ruby 3.0.0
- Rails 7.0.3.1
- Postgres 

## Middleware 

Session management middleware is excluded from API apps by default and must be included to make use of sessions and cookies for authentication.
The following settings have been added to  `config/application.rb`

```
config.middleware.use ActionDispatch::Cookies
config.middleware.use ActionDispatch::Session::CookieStore
```

and called by adding the following to `app/controllers/application_controller.rb`

```
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
```

Documentation link [rubyonrails.org](https://guides.rubyonrails.org/api_app.html#using-session-middlewares)


## CORS
Allows web applications to make cross-domain AJAX calls.<br> 
I.e. separately hosted frontend and backend applications are "allowed" to communicate. 

This project uses the Rack CORS gem, which creates the `config/initializers/cors.rb` file .

Note: `forgery_protection_origin_check = false` is set to false

Gem documentation [rack-cors](https://github.com/cyu/rack-cors)

Mozilla web security [same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy)


## bcrypt
Used to hash and store passwords securely.<br>
Note: the `User.my_password == "my password"` method only works within a session where the password has been set. <br>
It cannot be used to check passwords ad-hock. <br> 

Gem documentation [bcrypt-ruby](https://github.com/bcrypt-ruby/bcrypt-ruby)

Tutorial: Setting up bycrypt [medium](https://medium.com/@tpstar/password-digest-column-in-user-migration-table-871ff9120a5)


## Session Authentication 

### How it works

When a user signs up or signs in, the backend creates a session containing the user_id and passes it to the client (user's browser) as a cookie. 
The client then sends the session cookie to the backend with every subsequent request. <br>

The backend opens the session cookie and checks for a user_id; if present, the user is signed in. <br>
When the user signs out, the user_id is deleted from the session cookie. 

How Rails sessions work [justinweiss](https://www.justinweiss.com/articles/how-rails-sessions-work/)
  
### How are session cookies secured? 
When Rails creates a session cookie, it encrypts it using its secret_key_base <br>
The data held is inaccessible without first decrypting the cookie. 

>The cookie data is cryptographically signed to make it tamper-proof. And it is also encrypted so anyone with access to it can't read its contents. (Rails will not accept it if it has been edited).


Rails documentation [sessions](https://guides.rubyonrails.org/action_controller_overview.html#session)

Rails documentation [secret key base](https://apidock.com/rails/Rails/Application/secret_key_base)


### State
This implementation of session authentication is stateless

An authentication method is stateless when unique session information, such as a user_id, is stored in a cookie or token and sent with every HTTP request. The backend checks the user_id is valid before returning a 200 OK response and no additional calls are required. 

An authentication method is stateful when it stores unique information about the session in the backend using a DB table or Cache. This can include the user id, session id, user permissions, ip address, devise type, time of last request etc. The backend must fetch the session data for every request before returning a 200 OK response.


### Actions
| Action  | File |
| ------------- | ------------- |
| Create session on signs up  | app/controllers/users_controller.rb  |
| Create/destory session on sign in/sign out  | app/controllers/sessions_controller.rb  |
| Authenticate user on sign in  | app/models/user.rb  |
| Protect resources using current_user | app/controllers/application_controller.rb  |



## CSRF protection


### What is a CSRF attack 
> Briefly, Cross-Site Request Forgery (CSRF) is an attack that allows a malicious user to spoof legitimate requests to your server, masquerading as an authenticated user. Rails protects against this kind of attack by generating unique tokens and validating their authenticity with each submission  
  
CSRF attacks work because clients, by design, send all the cookies they have available with every request, regardless of the resources.
  
A Deep Dive into CSRF Protection in Rails [medium](https://medium.com/rubyinside/a-deep-dive-into-csrf-protection-in-rails-19fa0a42c0ef#:~:text=Briefly%2C%20Cross%2DSite%20Request%20Forgery,their%20authenticity%20with%20each%20submission)
  
### How does CSRF protection in Rails work
Rails uses a scripting adapter to implement the "Cookie-to-header" technique by placing a CSRF token in the client as a cookie and saving a duplicate in a custom HTTP header.
  
 > By default, Rails includes an unobtrusive scripting adapter, which adds a header called X-CSRF-Token with the security token on every non-GET Ajax call
The custom HTTP header looks like `X-Csrf-Token: i8XNjC4b8KVok4uw5RftR38Wgp2BFwql`. 
  
Rails docs [csrf countermeasures](https://guides.rubyonrails.org/security.html#csrf-countermeasures)

When the client makes a legitimate request, it passes the cookies, plus the custom HTTP header. The backend compares both tokens and autherrises the request if they match. If they dont match, the backend kills the session. 

Rails uses the `verified_request?()` method in the `ActionController::RequestForgeryProtection` module to compare the HTTP header with the CSRF token.<br>
```
verified_request?()Link
Returns true or false if a request is verified. Checks:
- Is it a GET or HEAD request? GETs should be safe and idempotent
- Does the form_authenticity_token match the given token value from the params?
- Does the X-CSRF-Token header match the form_authenticity_token?
```
Rails API docs [RequestForgeryProtection](https://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html#method-i-verified_request-3F)

  
The "Cookie-to-header" method is secure because although a clients cookies are automaticly sent with each request, the custom headers are not and their data is private so it cannot be coppied or sent with a malicius attack. 
  
 > Security of this technique is based on the assumption that only JavaScript running on the client side of an HTTPS connection to the server that initially set the cookie will be able to read the cookie's value. JavaScript running from a rogue file or email should not be able to successfully read the cookie value to copy into the custom header. Even though the csrf-token cookie will be automatically sent with the rogue request, the server will still expect a valid X-Csrf-Token header.
  
 Wikipedia [cross-site request forgery](https://en.wikipedia.org/wiki/Cross-site_request_forgery#Cookie-to-header_token)
  
This goes against the idea that `httpOnly` CSRF tokens cannot be read by JS, but we trust this method is secure becasue its baken into rails. 

Note: Resources cannot be accessed without a CSRF token except for GET resources which are not protected. <br>
When CSRF is enabled, use the events/index GET resource to collect a token. 

### Enable/disable CSRF protection
- Comment out `protect_from_forgery with: :exception` in `app/controllers/application_controller.rb` to disable CSRF protection

Pragmatic Studio [rails session cookies & CSRF for API applications](https://pragmaticstudio.com/tutorials/rails-session-cookies-for-api-authentication)
  
nvisium blog [understanding protect_from_forgery](https://blog.nvisium.com/understanding-protectfromforgery)

Understanding Rails' Forgery Protection Strategies [blog](https://marcgg.com/blog/2016/08/22/csrf-rails/)

Prevent Cross-Site Request Forgery (CSRF) Attacks [includes example project](https://auth0.com/blog/cross-site-request-forgery-csrf/)
  
  Basics of Cross Site Request Forgery (CSRF), and ways to prevent it in NodeJs and Ruby on Rails [blog](https://blog.geogo.in/cross-site-request-forgery-csrf-in-nodejs-and-ruby-on-rails-7e2004af292c)


## Password reset

### How it works 
The password resource is used to reset passwords.<br>

The forgot action checks the user and calls `UserMailer.forgot_email`, which generates a token and sends it to the user's email.<br>
The token is then passed back to the reset action and used to validate the request. 

To test the password reset function, call the forgot password endpoint and copy the token from the reset password email/response.<br>
Send a request to the reset password endpoint and add the token as a param and your email and new password in the JSON body.

### Generating tokens
The `signed_id` method is built into Rails and is used to generate tokens associated with users. <br>
The `signed_id` method is used in the `UserMailer` class. 
See the GoRails youtube links below for more info. <br>

`user.signed_id(expires_in 15.minutes, purpose: “password_reset”)`

Creating “Forgot password” feature on Rails API [medium](https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59)

“Welcome email” for new user using Action Mailer [medium](https://pascales.medium.com/welcome-email-for-new-user-using-action-mailer-becdb43ee6a)

Rails for Beginners Part 21: Reset Password Token Mailer [GoRails](https://www.youtube.com/watch?v=JMXGExhr0C4&ab_channel=GoRails)

Rails for Beginners Part 22: Password Reset Update [GoRails](https://www.youtube.com/watch?v=kTB5z4NcrhM&ab_channel=GoRails)




## Sending emails
ActionMailer is used to send emails from a test Gmail account when a user signs up or resets their password. <br>
Settings can be found in `config/environments/development.rb` 

Note: a password has been created for third-party access to the test Gmail account and stored in .env file.

  ```
  config.action_mailer.default_url_options = {
    host: 'localhost:3000',
    protocol: 'http'
  }
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    user_name: 'myrailsmail@gmail.com',
    password: ENV['GOOGLE_APP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
  ```

Emails work much the same as controllers and views. 

Default settings
`app/mailers/application_mailer.rb`

Base email template
`app/views/layouts/mailer.html.erb`

Spesific email templates
`app/views/user_mailer/...`


Implementing Action Mailer [medium](https://medium.com/nerd-for-tech/implementing-action-mailer-ruby-on-rails-1766f59c6f)




## Routing 
### Namespacing the API routes <br>
I decided not to namespace the routes because all routes are APIs, so we don't need to differentiate, and this template has no need for versioning.

### Route formatting
Routes are wrapped with `format: :json` <br>
This means the router expects all incoming requests to be for JSON resources, and we don't need to specify the format type in our URL requests. I.E `http://[::1]:3000/events` not `http://[::1]:3000/events.json`

Note: If we wanted to use other formats like XML, we would need to move this logic to the ActionController and create a before action to check the format of incoming requests.

### singular resources 
The password route and controller are singular.
The session route is singular, but the controller is plural.

Singular resources don't use IDs
>We can see singular resource routes don’t have ID of the resource. Moreover, it still directs requests to pluralized controller name.

difference between singular and plural resources [blog](https://www.rubyinrails.com/2019/04/16/rails-routes-difference-between-resource-and-resources/)


### Controller response formatting
Controller actions can respond differently depending on the request format, such as JSON, XML, TXT etc
Respond_to Without All the Pain [justinweiss](https://www.justinweiss.com/articles/respond-to-without-all-the-pain/


 ### Params
Session and event objects get their name from the controller the HTTP body is sent to.
```
Parameters: {"username"=>"orange", "*event*"=>{"username"=>"orange"}}
Parameters {"username"=>"orange", "format"=>:json, "controller"=>"sessions", "action"=>"create", "*session*"=>{"username"=>"orange"}} permitted: false>
```
Params Wrapper in Ruby on Rails Explained [medium](https://medium.com/ruby-daily/params-wrapper-in-ruby-on-rails-30e7921f7704)



### ENV File & Gitignore
A .env file has been added to the project route for storing sensitive info such as the 3rd party app password for sending emails. 

Using dotenv gem <br>
Note: .env file must be located in the root directory <br>

Gem documentation [Dotenv](https://github.com/bkeepers/dotenv)

Setting up .env files [using Dotenv-Rails gem](https://www.youtube.com/watch?v=Re0OYhw0GUY&ab_channel=ArachneTutorials)

#### Gitignore 
Create file in project route `touch .gitignore`
Add env file to ignore it 
```
#ignore env files
.env*
```

TODO
- [ ] Check if the session controller should be singular 
- [ ] Clean up reset password error response 
- [ ] Add secion on "has_secure_password doesn't wrap password"
- [ ] add httpOnly section [httpOnly]https://owasp.org/www-community/HttpOnly
- [ ] does scripting adapter technique break httpOnly?
- [ ] localStorage


