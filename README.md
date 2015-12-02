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

We need to establish a connection between the Rails view and the main component. To render `_main.js.jsx` in our root we need to add the view helper we get from react-rails. It puts a div on the page with the requested component class. Go ahead and delete the old code. Since we use React as our view layer, our Rails views are next to empty (as they should be).

```
app/views/site/index.html.erb

<%= react_component 'Main' %>
```

### 3. Component Hierarchy

We will end up having multiple components, but they will all stem from the main one. Components have parent-child relationships so if component Cat renders component Kitten, Cat is the parent of Kitten. For example, let's say we are building the component hierarchy for a site with a header, a side bar and tweets.

>
> The notation for rendering React components is <ComponentName />
>

The main component, `<Main />`, would render the `<Header />` and `<Body />` component. The `Header` and the `Body` exist independently of each other but they need to know about similar data such as the current user or which link in the header was clicked. We can store all that information and keep track of the current state of our application in `Main` and pass it to `Header` and `Body`. By storing the data in one place we are also only updating the data in one place - we have a so-called Single Source of Truth, one place where data is stored and updated.

In `<Body />`, we render `<Tweets />` and `<Ads />`. `Tweets` and `Ads` don't really depend on the same data but rendering both of them in the `Body` makes sense in this case. Finally, `<Tweets />` renders an entire collection of `<Tweet />`. Each individual tweet is a single component to keep it DRY:*Don't Repeat Yourself*.

```
          Main
        /      \  
       /        \
    Header       Body
                /     \
             Ads     Tweets
                          \___  
                              \___
                              |   Tweet
                              |       _\_  
                              |      /    \
                              |  Body   TweetOptionsBars       
                              |
                              |___
                              |   Tweet
                              |       _\_  
                              |      /    \
                              |  Body   TweetOptionsBars       
                              |
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

additional resources:
- (Thinking in React)[https://facebook.github.io/react/docs/thinking-in-react.html]
- (Video)[http://tagtree.tv/thinking-in-react] tutorial that walks through the code used in above article

### 4. Hello, Creact!

We did it! We have copy-pasted our first component and our Rails view is empty. Let's take a closer look at `Main`.

We have built a component and given it a name. It has only one function, `render()`. When a React component is mounted on the DOM, its `render()` method will execute and also trigger all of the component's children's `render()` methods. The code that is in the `return` statement is the JSX that will render on the page. Right now our HTML looks like regular HTML, but soon we will add in some JavaScript so it becomes more dynamic. Each React component can only return one HTML element, so all JSX needs to be wrapped in one wrapper div.

Bad - returning sibling HTML elements that aren't wrapped by a shared parent div will make your program fail.
```
return (
  <div>
    <h1>Hello, Creact!</h1>
  </div>
  <div>
    <p>All of the contents</p>
  </div>
)
```

Better - we have multiple sibling HTML elements which share a parent div. We return one HTML element and our JSX is valid.
```
return (
  <div>
    <div>
      <h1>Hello, Creact!</h1>
    </div>
    <div>
      <p>All of the contents</p>
    </div>
  </div>
)
```

Let's build a component hierarchy. We will build out basic crud functionality; **create**/new, **read***/index, **update**/edit, **delete**/destroy. Our `Main` component could render a `Header` and a `Body`. In the `Body`, we need to be able to view all skills, view an individual skill, create a new skill and delete a skill. So, `Body` could render `<NewSkill >` and `<AllSkills />`. `AllSkills` renders a collection of individual `Skill` components - each `Skill` component has it's own delete button.  

```
         Main
       /      \
  Header        Body
              /     \
        NewSkill    AllSkills
                        \  
                        Skills * n
```

Let's remove our current `h1` and add `<Header />` in it's place.


```
app/assets/javascripts/components/_main.js.jsx

var Main = React.createClass({
  render() {
    return (
      <div>
        <Header />
      </div>
    )
  }
});
```

We are rendering the `Header` component (still non-existent) in the `Main` component, `Header` is the child of `Main`.

```
$ touch app/assets/javascripts/components/_header.js.jsx
```

Our code for the `Header` component will look very similar to what we have in `Main`, but obviously we won't render the `Header` component in the return statement. For now, put an `h1` there with whatever text you want. Hop over to your browser to make sure the `h1` renders as it should. If not, take a look at what we first had in `Main`. The two are very similar. Let's leave the `Header` for now and move on to building out the body. We might come back a bit later to include the search functionality here.
       
