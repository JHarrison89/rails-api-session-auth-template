
<p align="center">
  <a href="https://rubyonrails.org/"><img width="300" src="https://zakaria.dev/assets/images/rails_base_app/Ruby_On_Rails_Logo.png" alt="Ruby On Rails"></a>

# Rails API session auth template
This Rails 7 API-only app is intended as a template to kick-start SPA projects using Rails as the server and a separate application as the front-end, such as Vue, React etc.

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

Session management middleware is excluded from API apps by default and must be included to make use of sessions and cookies for authentication and CSRF protection.
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

- Documentation link [rubyonrails.org](https://guides.rubyonrails.org/api_app.html#using-session-middlewares)


## CORS
Allows web applications to make cross-domain AJAX calls.<br> 
I.e. separately hosted frontend and backend applications are "allowed" to communicate. 

This project uses the Rack CORS gem, which creates the `config/initializers/cors.rb` file.

Note: `forgery_protection_origin_check = false` is set to false

- Gem documentation [rack-cors](https://github.com/cyu/rack-cors)

- Mozilla web security [same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy)


## bcrypt
Used to hash and store passwords securely.<br>
Note: the `User.my_password == "my password"` method only works within a session where the password has been set and cannot be used to check passwords ad-hock. <br> 

- Gem documentation [bcrypt-ruby](https://github.com/bcrypt-ruby/bcrypt-ruby)

- Tutorial: Setting up bycrypt [medium](https://medium.com/@tpstar/password-digest-column-in-user-migration-table-871ff9120a5)


## Session Authentication 

### How it works

When a user signs up or signs in, the backend creates a session containing the user_id and passes it to the client (user's browser) as a cookie. 
The client then sends the session cookie to the backend with every subsequent request. <br>

The backend opens the session cookie and checks for a user_id; if present, the user is considered signed in. <br>
When the user signs out, the user_id is deleted from the session cookie. 

- How Rails sessions work [justinweiss](https://www.justinweiss.com/articles/how-rails-sessions-work/)
  
### How are session cookies secured? 
When Rails creates a session cookie, it encrypts the entire cookie using its secret_key_base and must be decrypted to access its content.
>The cookie data is cryptographically signed to make it tamper-proof. And it is also encrypted so anyone with access to it can't read its contents. (Rails will not accept it if it has been edited).


- Rails documentation [sessions](https://guides.rubyonrails.org/action_controller_overview.html#session)

- Rails documentation [secret key base](https://apidock.com/rails/Rails/Application/secret_key_base)


### State
This implementation of session authentication is stateless

An authentication method is stateless when it does not store session information in the backend. This implementation of session authentication works by placing the user_id in the session cookie and validating it with each request; if valid, the user is considered signed in. 

An authentication method is stateful when it does store information about the session in the backend using a DB table or Cache. The session cookie holds the session ID (instead of a user ID), which is used to fetch and update records when necessary, and often requires more calls than stateless authentication. The pros of stateful authentication include capturing a range of user data; cons include storing and clearing data and an increase in backend requests.

Stateful authentication stores data such as user id, session id, user permissions, ip address, devise type, time of last request etc.


### Actions
| Action  | File |
| ------------- | ------------- |
| Create session on signs up  | app/controllers/users_controller.rb  |
| Create/destory session on sign in/sign out  | app/controllers/sessions_controller.rb  |
| Authenticate user on sign in  | app/models/user.rb  |
| Protect resources using current_user | app/controllers/application_controller.rb  |



## CSRF protection


### What is a CSRF attack 
> Briefly, Cross-Site Request Forgery (CSRF) is an attack that allows a malicious user to spoof legitimate requests to your server, masquerading as an authenticated user. Rails protects against this kind of attack by generating unique tokens and validating their authenticity with each submission. 
 
CSRF is an extensive subject, so I have written a blog explaining how Rails protects itself from CSRF attacks, including a step-by-step walkthrough and a section on Cookie security such as Secure attribute, HttpOnly and SameSite attribute. Please refer to this blog post for more details.

- How Cross-Site Request Forgery (CSRF)Attack Prevention Works in Rails [blog](https://medium.com/@jeremaia.harrison/how-cross-site-request-forgery-csrf-attack-prevention-works-in-rails-7be4176cf170)

### CSRF protection in this project
This Rails 7 API-only app is intended as a template to kick-start SPA projects using Rails as the server and a separate application as the front-end, such as Vue, React etc. As such, CSRF protection has been included but disabled. When a front-end, such as Vue, has been set up, CSRF protection can be enabled.

The following link explains how CSRF protection is intended to work in this project.<br>
- Pragmatic Studio [rails session cookies & CSRF for API applications](https://pragmaticstudio.com/tutorials/rails-session-cookies-for-api-authentication)


### Enable/disable CSRF protection
- uncomment `protect_from_forgery with: :exception` in `app/controllers/application_controller.rb` to enable CSRF protection


Note: Resources cannot be accessed without a CSRF token except for GET resources which are not protected. <br>
When CSRF is enabled, use the events/index GET resource to collect a token. 


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

- Creating “Forgot password” feature on Rails API [medium](https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59)

- “Welcome email” for new user using Action Mailer [medium](https://pascales.medium.com/welcome-email-for-new-user-using-action-mailer-becdb43ee6a)

- Rails for Beginners Part 21: Reset Password Token Mailer [GoRails](https://www.youtube.com/watch?v=JMXGExhr0C4&ab_channel=GoRails)

- Rails for Beginners Part 22: Password Reset Update [GoRails](https://www.youtube.com/watch?v=kTB5z4NcrhM&ab_channel=GoRails)




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

Specific email templates
`app/views/user_mailer/...`


- Implementing Action Mailer [medium](https://medium.com/nerd-for-tech/implementing-action-mailer-ruby-on-rails-1766f59c6f)




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
>We can see singular resource routes don’t have ID of the resource. Moreover, it still directs requests to pluralized controller names.

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
A .env file has been added to the project route for storing sensitive info, such as the 3rd party app password for sending emails. 

Using dotenv gem <br>
Note: .env file must be located in the root directory <br>

- Gem documentation [Dotenv](https://github.com/bkeepers/dotenv)

- Setting up .env files [using Dotenv-Rails gem](https://www.youtube.com/watch?v=Re0OYhw0GUY&ab_channel=ArachneTutorials)

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
- [ ] localStorage
- [ ] blog, session authenticaion vs JWT token


