# rails API session auth template
This Rails 7 API-only app is intended as a template to kick-start projects.

The app includes...

- stateless session authorisation 
- CSRF cookies 
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


## The Basics 
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

`config/initializers/cors.rb`<br>
Note: `forgery_protection_origin_check = false` is set to false

https://github.com/cyu/rack-cors
https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy



## bcrypt
Used to hash and store passwords securely.<br> https://medium.com/@tpstar/password-digest-column-in-user-migration-table-871ff9120a5

## How Session Authentication works 
When a user signs up or signs in, the backend creates a session containing the user_id and returns it to the frontend as a cookie. <br>
The frontend sends the session cookie with every subsequent request; the backend then opens the session cookie and checks for a user_id; if one is present, it means the user is signed in. <br>

When the user signs out, the user_id is deleted from the session cookie. 

The `authenticate_user` method in `app/controllers/application_controller.rb` protects resources by checking if current_user is set. <br>
The authenticate method in `app/models/user.rb` checks user credentials when signing in.

`app/controllers/users_controller.rb` <br>
`app/controllers/sessions_controller.rb`<br>
`app/models/user.rb`

### Is it dangerous to store the user_id in the session cookie? 
- Quote about rails cookies being secure


### What does stateless mean? 
Authorisation methods can be stateless or stateful.<br>
Stateless means no session information, such as the session_id, is stored or referenced by the backend.<br>
Stateful means session information is stored and referenced by the backend in a DB table or Cache. 

## How CSRF protection works 
CSRF protection works by placing a CSRF token in the user's browser, which is sent to the backend and checked with all subsequent requests.
Resources cannot be accessed without a CSRF token except for GET resources which are not protected. 

CSRF protection can be enabled/disabled by commenting out `protect_from_forgery with: :exception` <br>
in `app/controllers/application_controller.rb`

When CSRF is enabled, use the events/index GET resource to collect a token. 

https://medium.com/rubyinside/a-deep-dive-into-csrf-protection-in-rails-19fa0a42c0ef#:~:text=Briefly%2C%20Cross%2DSite%20Request%20Forgery,their%20authenticity%20with%20each%20submission

https://marcgg.com/blog/2016/08/22/csrf-rails/

## How password reset & works 
The password resource is used to reset passwords.<br>
The forgot action checks the user and calls `UserMailer.forgot_email`, which generates a token and sends it to the user's email.<br>
The token is then passed back to the reset action and used to validate the request. 

Call the forgot password endpoint to test the password reset function and copy the token from the reset password email.<br>
Sebd a request to reset the password endpoint and add the token as a param so it can be validated by the backend.

The `signed_id` method is built into Rails and is used to generate tokens associated with users. <br>
The `signed_id` method is used in the `UserMailer` class. 
See the GoRails youtube links below for more info. <br>

`user.signed_id(expires_in 15.minutes, purpose: “password_reset”)`

https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59

https://pascales.medium.com/welcome-email-for-new-user-using-action-mailer-becdb43ee6a

https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59

https://www.youtube.com/watch?v=JMXGExhr0C4&ab_channel=GoRails

https://www.youtube.com/watch?v=kTB5z4NcrhM&ab_channel=GoRails

https://medium.com/binar-academy/forgot-password-feature-on-rails-api-8e4a7368c59


## Sending emails
ActionMailer is used to send emails when a user signs up or resets their password. <br>
https://medium.com/nerd-for-tech/implementing-action-mailer-ruby-on-rails-1766f59c6f

Give third party apps access...
Custom settings 
config/environments/development.rb


## Routing 
singular resources 

### Params Wrapper
https://medium.com/ruby-daily/params-wrapper-in-ruby-on-rails-30e7921f7704

### Rails routes - why is session singular ?
https://www.rubyinrails.com/2019/04/16/rails-routes-difference-between-resource-and-resources/

 ### HTTP request 
Session and event objects get their name from the controller the HTTP body is sent to.
```
Parameters: {"username"=>"orange", "*event*"=>{"username"=>"orange"}}
Parameters {"username"=>"orange", "format"=>:json, "controller"=>"sessions", "action"=>"create", "*session*"=>{"username"=>"orange"}} permitted: false>
```


