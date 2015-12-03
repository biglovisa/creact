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

### 5. Rendering all skills

Now it's time to render all skills on the page. First, we need to add a `Body` component in which our `NewSkill` and `AllSkills` components will live.         

```
$ touch app/assets/javascripts/components/_body.js.jsx
$ touch app/assets/javascripts/components/_all_skills.js.jsx
```

Go ahead and add the "skeleton code" for both `Body` and `AllSkills`. `Body` should render `AllSkills`. Put an arbitrary `h1` in `AllSkills` so we can get some feedback on the page. At this point, two `h1`'s should be rendered on the page. If you don't, open up the dev tools (option + cmd + i) and see if you have any errors in the console. If they aren't useful, look over the syntax carefully and make sure it looks like what we have in `Main`.

Our next step is to fetch all skills from the server. This is JavaScript so we will use Ajax to ping the index action of our Rails API to get all the skills from the database. It's important that our Ajax call is only executed once. It's expensive to make Ajax calls and depending on the scale of your applications, it can cause performance issues. React components have some built in methods available that we can use to make our coding life a bit easier. In this case, we want a method that renders once when the component is mounted on the DOM - similar to jQuerys's `$(document).ready()`. We are going to use `componentDidMount()` which is called right after the component is mounted. For more details about methods that are available to components and when to use them, check out the [docs](https://facebook.github.io/react/docs/component-specs.html).

Functions we add to the component go above the `render()` statement. Let's add a `componentDidMount()` function and just `console.log()` something so we now it's being called.

```
var AllSkills = React.createClass({
  componentDidMount() {
    console.log('Hello');
  },

  render() {
    return (
      <div>
        <h1>Hello from All Skills!</h1>
      </div>
    )
  }
});
```

Why is there a comma at the end of our function? Take a closer look at the syntax. When we write `var AllSkills = React.createClass( /* Code here */ )` we give it an object containing all the code for the component. Since elements in objects are comma separated, we put a comma at the end of our functions.

Did you see the output from the `console.log()` in the browser console? Cool! Let's fetch some ideas.

```
$.getJSON('/api/v1/skills.json', (response) => { console.log(response) });
```

Make sure to take a look in the browser console, open up the objects to make sure everything looks good.

Right now we are just logging the result to make sure we get the objects we want. Really, what we want to do is to store it on the component so we can more easily use it. Data that will change is stored as `state` on the component. In React, state is mutable, so data that will change throughout the program should be stored as state. There's another handy method we get from React; `getInitialState`. Here, we specify the initial values for all the states in the component (usually you have several). Let's create a state called `skills` and set it equal to an empty array.

```
var AllSkills = React.createClass({
  getInitialState() {
    return { skills: [] }  
  },

// rest of the component
```

Now, when we get the response back from the server, we want to update `skills` and set it to the value of the skills we got from the server. We want to store it as state becasue when we add new skills, we want to be able to render them on the page without having to ping the index action of our API again. By using another of React's built in methods, this isn't bad at all.

```
  $.getJSON('/api/v1/skills.json', (response) => { this.setState({ skills: response }) });
```
To be sure that we actually updated the state, let's log the state (`console.log(this.state)`) in the `render()` method. Make sure to put it outside of the return statement! You should see something like this in your browser console. Change the `console.log` to log `this.state.skills` and check out the difference.

```
> Object {skills: Array[0]}
> Object {skills: Array[50]}
```

Why did we first get an empty array, and then immediately after an array with our 50 skills? `componentDidMount` runs immediately after the component has been mounted on the DOM. It already executed the `render()` method once before we had updated the state. Now that we have all skills as objects in an array, we can create DOM elements and render them on the page.

We eventually want to create a `Skill` component for each object in the skills array. For now, let's just map over the objects in the array and create DOM nodes out of them. Since JSX is just HTML + JS, we can build HTML elements and insert JavaScript wherever we need it, similar to how we can insert Ruby in HTML elements using erb.

```
// componentDidMount() and getInitialState()

render(
  var skills = this.state.skills.map((skill) => {
    return (
      <div>
        <h3>{skill.name}</h3>
        <p><strong>Level:</strong> {skill.level}</p>
        <p>{skill.details}</p>
      </div>
    )
  });

  return (
    <div>
      {skills}
    </div>
  )
)
```

The return value from the `this.state.skills.map...` will be an array of HTML divs, each with an `h3` and two `p` tags. As you can see, inserted JavaScript needs to be enclosed in curly braces - the erb equivalent to this would be `<%= %>`. In the return statement we have replaced the silly `h1` tag with the skills array we built above. In the return statement we write JSX and our skills array is JavaScript, so in order for it to be evaluated it needs to be wrapped in curly braces. Head over to the browser and make sure it all works ok!

You should see an error like this in the browser console:

```
Each child in an array or iterator should have a unique "key" prop. Check the render method of `AllSkills`. See https://fb.me/react-warning-keys for more information.
```

A key prop?

When we are rendering multiple similar HTML elements - in our case, 50 of the same type - we need to supply each with a unique key. React uses a diffing algorithm to figure out which parts of your application has changed and needs to be rerendered. It uses the keys to identify DOM nodes. This is partially what makes React so fast and snappy in the browser. For more details on this topic, check out the [docs](https://facebook.github.io/react/docs/reconciliation.html).

Let's help out React and add a key prop.

```
var skills = this.state.skills.map((skill, index) => {
  return (
    <div key={index}>
      <h3>{skill.name}</h3>
      <p><strong>Level:</strong> {skill.level}</p>
      <p>{skill.details}</p>
    </div>
  )
});
```  

The second argument in a map iteration is the index, so let's use it and add unique key props for all the skills we render. Refresh, and voila - no more errors.

### 6. Add a new skill

Now it's time to create a `NewSkill` component which will be rendered in the `Body` component.

```
$ touch app/assets/javascripts/components/_new_skill.js.jsx
```

Just like we did with the previous components, add the bare minimum and put an `h1` in the return statement to make sure it's properly rendering on the page.

```
var NewSkill = React.createClass({
  render() {
    return (
      <div>
        <h1>new skill</h1>
      </div>
    )
  }
});
```

What do we need to create a new skill? We need a form where the user can enter a name and details and a submit button which will take the input from the form and send it over to our server using Ajax. Let's start with the form. We are just going to use regular HTML to get the form and the submit button on the page. We add the refs to input fields to be able to fetch their value using `this.refs.name.value && this.refs.details.value`.  

```
return (
  <div>
    <input ref='name' placeholder='Enter name of skill' />
    <input ref='details' placeholder='Details' />
    <button>Submit</button>
  </div>
)
```

Cool cool cool! But what happens when the user has entered a new skill and hits submit? Nothing. Let's add an event listener.

```
<button onClick={this.handleClick}>Submit</button>
```

`onClick` is a React event listener, take a look at the [docs](https://facebook.github.io/react/docs/events.html) to learn about more. We give the event listener some JavaScript code to evaluate whenever we click the button. Here, we are telling it to go execute the `handleClick` function - which we haven't yet written.

```
// var NewSkill = ...

handleClick() {
  console.log('in handle click!')
},

// render()....
```

Great! Now, we need to fetch the form values and send it over to the server to create a new skill. Let's log the form values to be sure we have access to them.

```
let name    = this.refs.name.value;
let details = this.refs.details.value;
console.log(name, details);
```

Let's send the form values over to the server so we can create a new skill.

```
handleClick() {
  let name    = this.refs.name.value;
  let details = this.refs.details.value;

  $.ajax({
    url: '/api/v1/skills',
    type: 'POST',
    data: { skill: { name: name, details: details } },
    success: (response) => {
      console.log('it worked!', response);
    }
  });
},
```

We are making a POST request to '/api/v1/skills', sending over data and if we're successful, we log the response. Did it work? Create a new skill in the browser and check the browser console. Refresh the page to make sure your newly created skill is rendered on the page.

But we don't want to refresh the page to see our new skills. We can do better.

We store all the skills we get from the server as state in `AllSkills`. When we add a new skill, we could add it to the skills array so it will get rendered immediately with the other skills. `AllSkills` needs to read the values in the skills array and `NewSkill` wants to update that array. Both children of `Body` need access to the skills array so it make sense to store it as state in `Body` and give both children access to it.

So let's move some code around. Move `getInitialState()` and `componentDidMount()` to `Body`. Now, we fetch the skills when `Body` is mounted on the DOM and we store them as state on the `Body` component.

How does `AllSkills` get access to all the skills?

Parents can send variables down its children as `props`. `Props` are immutable in the child. Let's send the skills array from the `Body` component to the `AllSkills` component as props.

```
<AllSkills skills={this.state.skills} />
```

We have one more change to do before the skills will render on the DOM. In `AllSkills` we are iterating over `this.state.skills`. Only problem is that we no longer have a state store on the component. `AllSkills` receives the skills as props from the parent, so instead of `this.state.skills` we need to ask for `this.props.skills`.

```
var skills = this.props.skills.map((skill, index) => {
  return (
    <div key={index}>
      <h3>{skill.name}</h3>
      <p><strong>Level:</strong> {skill.level}</p>
      <p>{skill.details}</p>
    </div>
  )
});
```

Like we can pass down values from parents to children, we can also pass function references that can be executed in the child.

Let's starts from the `Body`. We want to build a function that's called `handleSubmit()` that will add the new skill to the skills array.

```
// getInitialState() and componentDidMount()

handleSubmit(skill) {
  console.log(skill);
},

// renders the AllSkills and NewSkill component
```

Then, we want to send a reference to this function down to the `NewSkill` component.

```
<NewSkill handleSubmit={this.handleSubmit} />
```

In the `NewSkill` component, we can call this function by adding parenthesis, just like a regular JavaScript function. In the `success` function, execute the `handleSubmit` function and give it the name and details as an object as an argument.

```
$.ajax({
  url: '/api/v1/skills',
  type: 'POST',
  data: { skill: { name: name, details: details } },
  success: (response) => {
    this.props.handleSubmit({name: name, details: details, level: 0});
  }
});
```

Check your browser console to see if you get any output from `handleSubmit` in the `Body` component.

```
Object {name: "some name", details: "some details", level: 0}
```

Yes! Almost there!

Now we need to add it to `this.state.skills`. We can use `concat()` to add the skill to the old state and then set the state with the new state.

```
handleSubmit(skill) {
  let newState = this.state.skills.concat(skill);
  this.setState({ skills: newState })
},
```

That's it! We have successfully added a new skill that is rendered on the DOM immediately.

Here is the code for `Body`, `AllSkills` and `NewSkill` in case you want to check your code.

```
app/assets/javascripts/components/_body.js.jsx

var Body = React.createClass({
  getInitialState() {
    return { skills: [] }
  },

  componentDidMount() {
    $.getJSON('/api/v1/skills.json', (response) => { this.setState({ skills: response }) });
  },

  handleSubmit(skill) {
    let newState = this.state.skills.concat(skill);
    this.setState({ skills: newState })
  },

  render() {
    return (
      <div>
        <NewSkill handleSubmit={this.handleSubmit} />
        <AllSkills skills={this.state.skills} />
      </div>
    )
  }
});
```

```
app/assets/javascripts/components/_all_skills.js.jsx

var AllSkills = React.createClass({
  render() {
    let skills = this.props.skills.map((skill, index) => {
      return (
        <div key={index}>
          <h3>{skill.name}</h3>
          <p><strong>Level:</strong> {skill.level}</p>
          <p>{skill.details}</p>
        </div>
      )
    });

    return (
      <div>
        {skills}
      </div>
    )
  }
});
```

```
app/assets/javascripts/components/_new_skill.js.jsx

var NewSkill = React.createClass({
  handleClick() {
    let name    = this.refs.name.value;
    let details = this.refs.details.value;

    $.ajax({
      url: '/api/v1/skills',
      type: 'POST',
      data: { skill: { name: name, details: details } },
      success: (response) => {
        this.props.handleSubmit({name: name, details: details, level: 0});
      }
    });
  },

  render() {
    return (
      <div>
        <input ref='name' placeholder='Enter name of skill' />
        <input ref='details' placeholder='Details' />
        <button onClick={this.handleClick}>Submit</button>
      </div>
    )
  }
});
```
