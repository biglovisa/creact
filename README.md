# Cract
## Crud + React

In this tutorial we are going to create a Rails API and a React front end to build
out basic CRUD functionality.

If you see anything that could be improved upon or should be corrected, please submit a PR!

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

### 2. Adding React to your Rails project

(React.js)[https://facebook.github.io/react/] is a "JavaScript library for building user interfaces". It's a tiny framework. You use it to create your view layer. React can be used in combination with almost any back
end, and with other view frameworks as well. React, as you will seee soon, can be sprinkled in
anywhere in your Rails application. React can be used for a search bar, be part of the nav
bar or the entire page can be build using React.

React is a JavaScript library and in Node applications we would just install it as a dependency. Fortunately, we can use the (react-rails)[https://github.com/reactjs/react-rails] gem so we can use React and JSX in our Rails applications. You'll get more familiar with JSX a bit further down, it's how we mix in JavaScript in HTML - the same way we can write erb to mix in Ruby in HTML.

Add `gem 'react-rails'` to your Gemfile.

```
$ bundle
$ rails g react:install
```

The last command generated a file, created a directory and inserted three lines to our code.

```
rails g react:install
  create  app/assets/javascripts/components
  create  app/assets/javascripts/components/.gitkeep
  insert  app/assets/javascripts/application.js
  insert  app/assets/javascripts/application.js
  insert  app/assets/javascripts/application.js
  create  app/assets/javascripts/components.js
```

If you open up `app/assets/javascripts/application.js` you'll see the three lines React inserted.

```
//= require react
//= require react_ujs
//= require components
```

Just like jQuery, we require `react`, `react_ujs` and `components` in our asset pipeline. In `app/assets/javascripts/components.js` we require the directory `components` which was also created for us. It's in this directory where all our React components will live. Think of a component almost as a class, it represents a "unit" of code. We build many small components that we combine to create bigger units of code.

Now we just need to connect our Rails views to our (yet non-existent) React code. First, add a file to the components directory. This will be our main file.   

```
$ touch app/assets/javascripts/components/_main.js.jsx
```

The `.js.jsx` extension is similar to `html.erb`. You are telling the browser that you are giving it jsx/erb and asking if it could please render js/html.

```
app/assets/javascripts/components/_main.js.jsx

var Main = React.createClass({
  render() {
    return (
      <div>
        <h1>Hello, Creact!</h1>
      </div>
    )
  }
});
```


The code we currently render at `http://localhost:3000` could be split into 3 components. One component that renders the title of the page, one component that renders all of the skills, and each individual skill would be its own component. https://facebook.github.io/react/docs/thinking-in-react.html
