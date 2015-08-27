### Setup
#### 1. Ruby Environment
This app is built in Sinatra and has no external database dependencies; instead it relies on the SQLite3 database. It does, however, require a Ruby 2.2.2 execution environment to be present. I've include `.ruby-version` and `.ruby-gemset` files which can be used by RVM; any other Ruby environment (assuming the same version) will probably work but may produce gem conflicts.

#### 2. Download

#### 3. Setup Database and Start Server
In the application directory, run the following:

1. `$ bundle install` - This will pull in dependencies from their remote repositories.

2. `$ bundle exec rake db:create` - This will create the sqlite3 database file

3. `$ bundle exec rake db:migrate` - This runs database migrations to set up tables

4. Edit `app.rb` and find the `SS_CLIENTID` constant on line 8. Add a valid Smartsheet client ID in the quotes. Find the `SS_APPSECRET` constant on line 9. Add a valid Smartsheet application secret in the quotes. __The application will not function without these values__

5. `$ rackup` - Starts the server and shows the console

#### 4. Load the Application
Open a browser, and point it to [http://localhost:9292](http://localhost:9292). You'll see a very simple screen with a button to launch the Smartsheet OAuth2 flow.

---

#### What works?
- Smartsheet API version 2.0
- Button to launch web-based auth flow
- Retrieve and persist home structure
- Home structure now persisted as full models
- Home page from persisted home structure
- Home page contents
  - user's email address
  - sheet picker
  - sheet columns dropdown (actually, used a popover)
- Extra credit!
  - collapsing tree structure (it's just a Bootstrap collapse hack, but it works)

#### What's new in this version?
- Now running on heroku at [http://sleepy-canyon-2701.herokuapp.com](http://sleepy-canyon-2701.herokuapp.com).
- Now uses PostgreSQL instead of SQLite3 because Heroku doesn't like SQLite3.
- The home structure was previously persisted as a JSON blob in a very simple model, and was parsed on-demand
as a nested set of ruby objects. In this version, I've expanded the home structure into a more full-featured
model, using single-table inheritance for the root of the structure itself, and its folders and workspaces.
To this end, I have created a `Container` datatype, which implements a `container_id` attribute - a foreign key
to an object in the same table which Smartsheet indicates is the parent of the object - and a `type` attribute,
which allows me to subclass the Container model as 3 different datatypes: `Home`, `Folder`, and `Workspace`. In
this way, I can change the inheritance rules based on what sort of data container I'm working with; e.g. a Home
object can contain Sheets, Folders, and Workspaces - but Folders and Workspaces cannot contain Workspaces. All
three subtypes can contain Sheets, which are stored in a separate table and implement their own `container_id`
attribute.

#### What doesn't work?
- The queries are inefficient. In an earlier revision, I also had each Container and Sheet subtype object also
include a reference to the Home object of which it was an eventual child. I planned to implement eager-loading
of a Home structure's child objects, since it's known they're all going to be displayed (in this use-case) anyway.
This worked in that it did preload the objects correctly, but I ran into namespace conflicts with ActiveRecord,
in that AR knew we had pre-loaded objects of type Container, but not of type Folder or Workspace. If I can solve
for that problem, then eager loading will make the queries MUCH faster.
- While there is an expanded data model in place, the problem of canonicality is addressed via brute-force. Every
time a user loads the app screen, the Home model deletes all of its child objects before replacing them from a
fresh get of the Home structure data from the API. I would have liked to build an optimizing data-expirer, but
I judged that to be slightly outside the scope of the task. It is on my feature list, however.
- I didn't have enough time to add in the token refresh that I wanted to.
- It's definitely not pretty. I used default Bootstrap components because they were ready at hand. They work, but they definitely aren't amazing.

#### What would I do differently next time?
- This would have been a great place to work in a React.js/Flux application
- If I had enough time and room on the road to change environments, I'd probably try to do this with a different language, perhaps node or python.
- I'd love to make this look better, but I chose function over form
