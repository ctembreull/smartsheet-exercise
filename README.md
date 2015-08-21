### Setup
#### 1. Ruby Environment
This app is built in Sinatra and has no external database dependencies; instead it relies on the SQLite3 database. It does, however, require a Ruby 2.2.2 execution environment to be present. I've include `.ruby-version` and `.ruby-gemset` files which can be used by RVM; any other Ruby environment (assuming the same version) will probably work but may produce gem conflicts.

#### 2. Download

#### 3. Setup Database and Start Server
In the application directory, run the following:

1. `$ bundle install` - This will pull in dependencies from their remote repositories.

2. `$ bundle exec rake db:create` - This will create the sqlite3 database file

3. `$ bundle exec rake db:migrate` - This runs database migrations to set up tables

4. `$ rackup` - Starts the server and shows the console

#### 4. Load the Application
Open a browser, and point it to [http://localhost:9292](http://localhost:9292). You'll see a very simple screen with a button to launch the Smartsheet OAuth2 flow.

---

#### What works?
- Smartsheet API version 2.0
- Button to launch web-based auth flow
- Retrieve and persist home structure
- Home page from persisted home structure
- Home page contents
  - user's email address
  - sheet picker
  - sheet columns dropdown (actually, used a popover)
- Extra credit!
  - collapsing tree structure (it's just a Bootstrap collapse hack, but it works)

#### What doesn't work?
- I ran out of time before being able to persist an expanded version of the model. As things stand right now, I persist the JSON home structure for the user as text, and then make that available to the page via tableless models that we create by parsing the JSON and exploding it into an object structure. With more time, I'd add the persistence backing for those models and do the JSON-explode operation when I retrieve the structure, instead of when the user loads the app.
- I didn't have enough time to add in the token refresh that I wanted to.
- It's definitely not pretty. I used default Bootstrap components because they were ready at hand. They work, but they definitely aren't amazing.

#### What would I do differently next time?
- If I had enough time and room on the road to change environments, I'd probably try to do this with a different language, perhaps node or python.
- I'd love to make this look better, but I chose function over form
