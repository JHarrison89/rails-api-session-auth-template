# rails API session auth template
This Rails 7 API-only app is intended as a template to kick-start projects.

The app includes...

- stateless session authorisation 
- CSRF cookies 
- REST endpoints for 
- - sign-up 
- - sign in 
- - sign out 
- - forgot password 
- - reset password 
- - event (Dummy resource for demo purposes)
- Action mail 
- - sends a sign-up email 
- - sends a password reset email


## The Basics 
- Ruby 3.0.0
- Rails 7.0.3.1
- Postgres 

## Middleware 
Unlike a standard Rails app, Rails API-only apps do not have cookie middleware enabled by default. 

The following cookie middleware settings have been added to `config/application.rb`

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
CORS allows web applications to make cross-domain AJAX calls. I.e. separately hosted frontend and backend applications are "allowed" to communicate. 

`config/initializers/cors.rb`
Note: `forgery_protection_origin_check = false` is set to false

https://github.com/cyu/rack-cors
https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy



## bcrypt
Used to hash and store passwords securely. https://medium.com/@tpstar/password-digest-column-in-user-migration-table-871ff9120a5

## How Session Authentication works 
When a user signs up or signs in, the backend creates a session containing the user_id and returns it to the frontend as a cookie. 

The frontend sends the session cookie with every subsequent request; the backend then opens the session cookie and checks for a user_id; if one is present, it means the user is signed in.

When the user signs out, the user_id is deleted from the session cookie. 

The `authenticate_user` method in app/controllers/application_controller.rb protects resources by checking if current_user is set. 

The authenticate method in `app/models/user.rb` checks user credentials when signing in.

`app/controllers/users_controller.rb`
`app/controllers/sessions_controller.rb`
`app/models/user.rb`

Is it dangerous to store the user_id in the session cookie? 
- Quote about rails cookies being secure…


What does stateless mean? 
- Authorisation methods can be stateless or stateful.
Stateless means no session information, such as the session_id, is stored or referenced by the backend.

 Stateful means session information is stored and referenced by the backend in a DB table or Cache. 

## How CSRF protection works 
CSRF protection works by placing a CSRF token in the user's browser, which is sent and checked with all subsequent requests. 

Resources cannot be accessed without a CSRF token except for GET resources which are not protected. 

In this app, use the events/index GET resource to collect a token. 

CSRF protection can be disabled by commenting out `protect_from_forgery with: :exception` in `app/controllers/application_controller.rb`

# protect_from_forgery with: :exception - comment out to turn CSRF off for incoming requests # when protect_from_forgery with: :exception on, visit a GET rout first to collect a CSRF token protect_from_forgery with: :exception

https://medium.com/rubyinside/a-deep-dive-into-csrf-protection-in-rails-19fa0a42c0ef#:~:text=Briefly%2C%20Cross%2DSite%20Request%20Forgery,their%20authenticity%20with%20each%20submission

https://marcgg.com/blog/2016/08/22/csrf-rails/

## How password reset & works 
The password resource is used to reset passwords via two custom methods, forgot_password and reset_password. 

The forgot action checks the user and calls the UserMailer.forgot_email method, which generates a token and sends it to the user's email.

The token is then passed back to the reset action and used to validate the request. 

Call the forgot password endpoint to test the password reset function and copy the token from the reset password email. 

Set up a request to reset the password endpoint and add the token as a param so it is passed to the backend and can be validated.

 user.signed_id(expires_in 15.minutes, purpose: “password_reset”)

https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59

https://pascales.medium.com/welcome-email-for-new-user-using-action-mailer-becdb43ee6a

https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59

https://www.youtube.com/watch?v=JMXGExhr0C4&ab_channel=GoRails

https://www.youtube.com/watch?v=kTB5z4NcrhM&ab_channel=GoRails

https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59

https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59

## Sending emails
ActionMailer is used to send emails when a user signs up or resets their password. 

https://medium.com/nerd-for-tech/implementing-action-mailer-ruby-on-rails-1766f59c6f

Give third party apps access...
Custom settings 
config/environments/development.rb


# Routing 
singular resources 

Params Wrapper
[Params Wrapper in Ruby on Rails Explained | by GreekDataGuy | Ruby Daily | Medium](https://medium.com/ruby-daily/params-wrapper-in-ruby-on-rails-30e7921f7704)

Rails routes - why is session singular ?
[Rails routes difference between resource and resources](https://www.rubyinrails.com/2019/04/16/rails-routes-difference-between-resource-and-resources/)

 HTTP request 
Session and event objects get their name from the controller the HTTP body is sent to.
```
Parameters: {"username"=>"orange", "*event*"=>{"username"=>"orange"}}
Parameters {"username"=>"orange", "format"=>:json, "controller"=>"sessions", "action"=>"create", "*session*"=>{"username"=>"orange"}} permitted: false>
```


