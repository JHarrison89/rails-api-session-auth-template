
<p align="center">
  <a href="https://rubyonrails.org/"><img width="300" src="https://zakaria.dev/assets/images/rails_base_app/Ruby_On_Rails_Logo.png" alt="Ruby On Rails"></a>

# Rails API session auth template
This Rails 7 API-only app is intended as a template to kick-start projects.

[![](https://badgen.net/badge/Rails/7.0.3.1/red)](https://github.com/JHarrison89/rails-api-session-auth-template/blob/main/Gemfile.lock)
[![](https://badgen.net/badge/Ruby/3.0.0/orange)](https://github.com/JHarrison89/rails-api-session-auth-template/blob/main/Gemfile.lock)

The app includes...

- stateless session authorisation 
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
Unlike a standard Rails app, Rails API-only apps don't have cookie middleware enabled by default. <br>
The following settings have been added to `config/application.rb`

```
config.middleware.use ActionDispatch::Cookies
config.middleware.use ActionDispatch::Session::CookieStore
```

and called by adding the following to `app/controllers/application_controller.rb`

```
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
```


## CORS
CORS allows web applications to make cross-domain AJAX calls.<br> 
I.e. separately hosted frontend and backend applications are "allowed" to communicate. 

This project uses the Rack CORS gem which creates the `config/initializers/cors.rb` file .

Note: `forgery_protection_origin_check = false` is set to false

Gem documentation [rack-cors](https://github.com/cyu/rack-cors)

Mozilla web security [same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy)


## bcrypt
Used to hash and store passwords securely.<br>
Note: the `User.my_password == "my password"` method only works within a session where the password has been set. <br>
It cannot be used to check passwords adhock. <br> 

Gem documentation [bcrypt-ruby](https://github.com/bcrypt-ruby/bcrypt-ruby)

Tutorial: Setting up bycrypt [medium](https://medium.com/@tpstar/password-digest-column-in-user-migration-table-871ff9120a5)


## How Session Authentication works 
When a user signs up or signs in, the backend creates a session containing the user_id and passes it to the client (users browser) as a cookie. 
The client then sends the session cookie to the backend with every subsequent requet. <br>

The backend then opens the session cookie and checks for a user_id; if one is present, it means the user is signed in. 
When the user signs out, the user_id is deleted from the session cookie. 


| Action  | File |
| ------------- | ------------- |
| Create session on signs up  | app/controllers/users_controller.rb  |
| Create/destory session on sign in/sign out  | app/controllers/sessions_controller.rb  |
| Authenticate user on sign in  | app/models/user.rb  |
| Protect resources using current_user | app/controllers/application_controller.rb  |


### How are session cookies secured? 
When Rails creates a session cookie it encrypts it using its secret_key_base <br>
Data is data is inaccessible without first decrypting the cookie.  

Documentation link [secret key base](https://apidock.com/rails/Rails/Application/secret_key_base)




### What does stateless mean? 
Authorisation methods can be stateless or stateful.<br>
- Stateless: no session information, such as the session_id, is stored or referenced by the backend
- Stateful: session information is stored and referenced by the backend in a DB table or Cache

## How CSRF protection works 
CSRF protection works by placing a CSRF token in the client (users browser).  <br> 
The client sends the token to the backend with every subsequent requet. <br>
The backend checks the token is valid before a request is processed. <br>

Resources cannot be accessed without a CSRF token except for GET resources which are not protected. <br>

When CSRF is enabled, use the events/index GET resource to collect a token. 

#### Enable/disable CSRF protection
- Comment out `protect_from_forgery with: :exception` in `app/controllers/application_controller.rb` to disable CSRF protection

A Deep Dive into CSRF Protection in Rails [medium](https://medium.com/rubyinside/a-deep-dive-into-csrf-protection-in-rails-19fa0a42c0ef#:~:text=Briefly%2C%20Cross%2DSite%20Request%20Forgery,their%20authenticity%20with%20each%20submission)

Understanding Rails' Forgery Protection Strategies [blog](https://marcgg.com/blog/2016/08/22/csrf-rails/)



## How password reset & works 
The password resource is used to reset passwords.<br>
The forgot action checks the user and calls `UserMailer.forgot_email`, which generates a token and sends it to the user's email.<br>
The token is then passed back to the reset action and used to validate the request. 

Call the forgot password endpoint to test the password reset function and copy the token from the reset password email.<br>
Send a request to reset the password endpoint and add the token as a param so it can be validated by the backend and your new email and password as a JSON body.

The `signed_id` method is built into Rails and is used to generate tokens associated with users. <br>
The `signed_id` method is used in the `UserMailer` class. 
See the GoRails youtube links below for more info. <br>

`user.signed_id(expires_in 15.minutes, purpose: “password_reset”)`

Creating “Forgot password” feature on Rails API [medium](https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59)

“Welcome email” for new user using Action Mailer [medium](https://pascales.medium.com/welcome-email-for-new-user-using-action-mailer-becdb43ee6a)

Rails for Beginners Part 21: Reset Password Token Mailer [GoRails](https://www.youtube.com/watch?v=JMXGExhr0C4&ab_channel=GoRails)

Rails for Beginners Part 22: Password Reset Update [GoRails](https://www.youtube.com/watch?v=kTB5z4NcrhM&ab_channel=GoRails)




## Sending emails
ActionMailer is used to send emails when a user signs up or resets their password. <br>


Implementing Action Mailer [medium](https://medium.com/nerd-for-tech/implementing-action-mailer-ruby-on-rails-1766f59c6f)

Give third party apps access...
Custom settings 
config/environments/development.rb


## Routing 
### Namespacing the API routes <br>
I decided not to namespace the API routes because all routes are APIs, so we dont need to diferenciate, and this template has no need version the APIs at this stage. 

## Route formatting
routes are wrapped with `format: :json` <br>
This means the router expects all incoming requiests to be for JSON resources and we dont need to spesify the format type in our URL requests. <br>
I.E we use `http://[::1]:3000/events` not `http://[::1]:3000/events.json`

Note: If we wanted to use other formats like XML, we would need to move this logic to the ActionController and creating a before action to check the format of incoming requests

Respond_to Without All the Pain [justinweiss](https://www.justinweiss.com/articles/respond-to-without-all-the-pain/)


### singular resources 
The password route and controller is singular 
The session route is singular but the controller is plural

**needs more research

https://www.rubyinrails.com/2019/04/16/rails-routes-difference-between-resource-and-resources/


### Params Wrapper
https://medium.com/ruby-daily/params-wrapper-in-ruby-on-rails-30e7921f7704


 ### HTTP request 
Session and event objects get their name from the controller the HTTP body is sent to.
```
Parameters: {"username"=>"orange", "*event*"=>{"username"=>"orange"}}
Parameters {"username"=>"orange", "format"=>:json, "controller"=>"sessions", "action"=>"create", "*session*"=>{"username"=>"orange"}} permitted: false>
```

 ### ENV File
Using dotenv gem <br>
Note: .env file must be located in the root directory <br>

Gem documentation [Dotenv](https://github.com/bkeepers/dotenv)

Setting up .env files [using Dotenv-Rails gem](https://www.youtube.com/watch?v=Re0OYhw0GUY&ab_channel=ArachneTutorials)



