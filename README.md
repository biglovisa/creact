# Cract
## Crud + React

In this tutorial we are going to create a Rails API and a React front end to build
out basic CRUD functionality.

### up and running

```
$ git clone git@github.com:applegrain/creact.git
$ rake db:{create,migrate,seed}
```

run tests with

```
$ bundle exec rspec
```

and start the server with

```
$ bundle exec rails s
```

### 1. What's already here?

If you start the server and go to `http://localhost:3000` you'll see an `h1` tag
and a bunch of skills - each with a name, details and a level set as (enum)[http://guides.rubyonrails.org/4_1_release_notes.html#active-record-enums]. The seed data doesn't
really reflect the fact that it is a skill. Feel free to change the `Faker` options
in `db/seeds.rb`.

So, in `config/routes.rb` we see that we already have a root set up. This will be the
only view we are going to use. We also have a `app/controllers/site_controller.rb` with
an index action that passes the instance variable `@skills` to the view. In the view,
`app/views/site/index.html.erb` we are iterating over `@skills` to render all the
skills on the DOM. Eventually we are going to delete the instance variable in the action
and remove everything from the view. But not yet.

In `config/routes.rb` there is also namespace `skills` resources. Since this is a crud + React
tutorial, the json API is already built out with the necessary actions. Jump over to
`app/controllers/api/v1/skills_controller.rb` and take a look. If you need more practice
with building json API's, check out this [video](https://vimeo.com/134915023).
