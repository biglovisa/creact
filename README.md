# Creact
## Crud + React

In this tutorial we are going to clone down a repo with a Rails API and build out a React front end using the [react-rails](https://github.com/reactjs/react-rails) gem. We won't cover the Rails API in detail and it is assumed that you are familiar with the general structure of a Rails project and JavaScript syntax.

### Sections

* [0. Up and running](https://github.com/applegrain/creact/blob/master/README.md#0-up-and-running)
* [1. What's already here?](https://github.com/applegrain/creact/blob/master/README.md#1-whats-already-here)
* [2. Adding React to your Rails project](https://github.com/applegrain/creact/blob/master/README.md#2-adding-react-to-your-rrails-project)
* [3. Component Hierarchy](https://github.com/applegrain/creact/blob/master/README.md#3-component-hierarchy)
* [4. Our first React component](https://github.com/applegrain/creact/blob/master/README.md#4-our-first-react-component)
* [5. Hello, Creact!](https://github.com/applegrain/creact/blob/master/README.md#5-hello-creact)
* [6. Rendering all skills](https://github.com/applegrain/creact/blob/master/README.md#6-rendering-all-skills)
* [7. Add a new skill](https://github.com/applegrain/creact/blob/master/README.md#7-add-a-new-skill)
* [8. Delete a skill](https://github.com/applegrain/creact/blob/master/README.md#8-delete-a-skill)
* [9. Edit a skill](https://github.com/applegrain/creact/blob/master/README.md#9-edit-a-skill)
* [10. Updating the level of a skill](https://github.com/applegrain/creact/blob/master/README.md#10-updating-the-level-of-a-skill)
* [11. Refactor](https://github.com/applegrain/creact/blob/master/README.md#11-refactor)
* [12. You are awesome](https://github.com/applegrain/creact/blob/master/README.md#12-you-are-awesome)

<br>

### 0. Up and running
---

In your terminal, clone the project:

```
$ git clone git@github.com:applegrain/creact-starter.git
$ rake db:{create,migrate,seed}
```

If you are having troubles with the above commands and get something like `NoMethodError for details=` run the following: 

```
$ rake db:{drop,setup}
```

`rake db:setup` will run `schema:load` to do the migrations instead of manually migrating them. If we just run regular migrations, it's as if the migrations hasn't completed before we start using them in our seed file. If anyone knows why, PR's accepted!

run tests with:


```
$ bundle exec rspec
```

and start the server with:

```
$ bundle exec rails s
```

<br>

### 1. What's already here?
---

If you start the server and go to `http://localhost:3000` you'll see an `h1` tag
and many skills - each with a name, details and a level set as [enum](http://guides.rubyonrails.org/4_1_release_notes.html#active-record-enums). The seed data doesn't
really reflect the fact that it is a skill. Feel free to change the [Faker](https://github.com/stympy/faker) options
in `db/seeds.rb`.

In `config/routes.rb` there is already a root path set up. This will be the
only route we are going to use. We also have a `app/controllers/site_controller.rb` with
an index action that passes the instance variable `@skills` to the view. In the view,
`app/views/site/index.html.erb`, we are iterating over `@skills` to render all the
skills on the DOM. Later we are going to delete the instance variable in the action
and have an almost empty view.

In `config/routes.rb` there is also routes for `Api::V1::Skills`. The json API is already built out with the necessary actions. In `app/controllers/api/v1/skills_controller.rb` we are serving json from four endpoints.

Further resources on building a json API

- [build a json API (code-along)](https://vimeo.com/134915023).

<br>

### 2. Adding React to your Rails project
---

[React.js](https://facebook.github.io/react) is a "JavaScript library for building user interfaces". It's a tiny framework used to build your view layer. React can be used in combination with almost any back
end, and can be combinded with other front end frameworks as well. React, can be sprinkled in
anywhere in your Rails application. React could be used for a search bar, be part of the nav
bar or be used for the whole page.

React is a JavaScript library but fortunately we can use the (react-rails)[https://github.com/reactjs/react-rails] gem that enables us to use React and JSX in our Rails application. You'll get more familiar with JSX a bit further down but it's basically the equivalent to erb. It's how we mix JavaScript with HTML - the same way we can mix Ruby with HTML when we use erb.

<br>

Add `gem 'react-rails'` to your Gemfile.

<br>

```
$ bundle
$ rails g react:install
```

The last command generated a file, created a directory and inserted three lines to our code.

<br>

```

$ rails g react:install
    create  app/assets/javascripts/components
    create  app/assets/javascripts/components/.gitkeep
    insert  app/assets/javascripts/application.js
    insert  app/assets/javascripts/application.js
    insert  app/assets/javascripts/application.js
    create  app/assets/javascripts/components.js

```

<br>

If you open up `app/assets/javascripts/application.js` you'll see the three lines React inserted.

<br>

```

//= require react
//= require react_ujs
//= require components

```

<br>

Just like jQuery, we require `react`, `react_ujs` and `components` to the asset pipeline. In `app/assets/javascripts/components.js` we require the directory `components`. It's in this directory where all our React components will live. Think of a component as a type of class, it represents a "unit" of code. We build many small components that we combine to build bigger features.

<br>

### 3. Component Hierarchy
---

The notation for rendering React components is: <ComponentName />.

Components have parent-child relationships, if component "Cat" renders component "Kitten", "Cat" is the parent of "Kitten". As an example, let's build the component hierarchy for a site with a header, a side bar and tweets:

The main component, `<Main />`, will render the `<Header />` and `<Body />` component. The `Header` and the `Body` components exist independently of each other but they need to know about similar data, such as the current user or which link in the header was clicked last. We can store that information and keep track of the current state of our application in `Main` and pass it down to `Header` and `Body`. By storing the data in one place we are also only updating the data in one place - we have a so-called "Single Source of Truth", one place where data is stored and updated.

In `<Body />`, we render `<Tweets />` and `<Ads />`. `<Tweets />` and `<Ads />` don't really depend on the same data but rendering both of them in the `Body` makes sense since they might share styling attributes. Finally, `<Tweets />` renders an entire collection of `<Tweet />`. Each individual tweet is a single `Tweet` component to keep it DRY: "Don't Repeat Yourself".

<br>

```

          Main
        /      \
       /        \
    Header       Body
                /     \
             Ads     Tweets
                          \______
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
                              etc

```

additional resources on component hierarchy:
- [Thinking in React](https://facebook.github.io/react/docs/thinking-in-react.html)
- [Video](http://tagtree.tv/thinking-in-react) tutorial that walks through the code used in above article


### 4. Our first component
---

Now we need to connect our Rails views to our (yet non-existent) React code. First, add a file to the components directory. This will be our main file.

<br>

```
$ touch app/assets/javascripts/components/_main.js.jsx
```

<br>

The `.js.jsx` extension is similar to `html.erb`. You are telling the browser that you are giving it jsx/erb and asking if it could please render js/html.

Then we establish a connection between the Rails view and the main component. To render `_main.js.jsx` in our root we need to add the view helper we get from the react-rails gem. It puts a div on the page with the requested component class. Go ahead and delete the old code in the view. Since we use React as our view layer, our Rails views are next to empty (as they should be).

<br>

**app/views/site/index.html.erb**
```

<%= react_component 'Main' %>

```

<br>
And let's add our first React component - head to the browser and make sure it works.
<br>

**app/assets/javascripts/components/_main.js.jsx**
```

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

<br>

### 5. Hello, Creact!
---

We did it! We have copy-pasted our first component and our Rails view is empty. Let's take a closer look at `Main`.

We have built a component and given it a name. It has only one function, `render()`. When a React component is mounted on the DOM, its `render()` method will execute and also trigger it's children's `render()` methods. The code that's in the `return` statement is the JSX that will render on the page. Right now our HTML looks like regular HTML, but soon we will add in some JavaScript so it becomes more dynamic. Each React component can only return one element, so all JSX elements in the return statement need to be in one wrapper div.

<br>

*Bad - returning sibling HTML elements that aren't wrapped by a shared parent div.*

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

<br>

*Better - we have multiple sibling HTML elements which share a parent div.*

<br>

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

<br>

Let's build out the component hierarchy. We are going to implement basic CRUD functionality; **create**, **read***, **update**, **delete**. Our `Main` component could render a `Header` and a `Body`. In the `Body`, we need to be able to view all skills, create a new skill, edit a skill and delete a skill. So, `Body` could render `<NewSkill />` and `<AllSkills />`. `NewSkill` is a form to create new skills and `AllSkills` renders a collection of individual `Skill` components - each `Skill` component has it's own delete and edit button.

<br>

```

         Main
       /      \
  Header        Body
              /     \
        NewSkill    AllSkills
                        \
                        Skills * n

```

<br>

Let's remove our current `h1` and add `<Header />` in it's place.

<br>

**app/assets/javascripts/components/_main.js.jsx**
```
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

<br>

We are rendering the `Header` component (still non-existent) in the `Main` component, which makes `Header` the child of `Main`.

<br>

```
$ touch app/assets/javascripts/components/_header.js.jsx
```

<br>

Our code for the `Header` component will look very similar to what we have in `Main`. For now, put an `h1` in the return statement with whatever text you want. Hop over to your browser to make sure the `h1` renders as it should. If not, take a look at the code we first had in `Main` and compare the syntax. Let's leave the `Header` for now and move on to building out the body.

<br>

### 6. Rendering all skills
---

Now let's render all skills on the page. First, we need to add a `Body` component in which our `NewSkill` and `AllSkills` components will be rendered.

```
$ touch app/assets/javascripts/components/_body.js.jsx
$ touch app/assets/javascripts/components/_all_skills.js.jsx
$ touch app/assets/javascripts/components/_new_skill.js.jsx
```

Go ahead and add the code from `Header` in the `Body`, `AllSkills` and `NewSkill` components. `Body` should render `AllSkills`. Put an arbitrary `h1` in `AllSkills` so we can get some feedback on the page. At this point, two `h1`'s should be rendered on the page. If they don't, open up the dev tools (option + cmd + i) and see if you have any errors in the console. If they aren't useful, look over the syntax carefully and make sure it looks like what we have in `Main`.

Our next step is to fetch all skills from the server. We will use Ajax to ping the index action of our Rails API to get all the skills from the database. It's important that our Ajax call is only executed once. It's expensive to make Ajax calls and depending on the scale of your applications, it can cause performance issues. If we were using jQuery, we would implement this in a `$(document).ready()` function.

React components have some built in methods available that execute during different points during a component's lifecycle. Some examples include functions that execute before/after a component mounts on the DOM and before/after it dismounts. In this case, we want a method that renders once when the component is mounted on the DOM. We are going to use `componentDidMount()` which is called right after the component is mounted. For more details about methods that are available to components and when to use them, check out the [docs](https://facebook.github.io/react/docs/component-specs.html).

Let's add a `componentDidMount()` function and just `console.log()` something so we now it's being called.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
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

<br>

Why is there a comma at the end of our function? Take a closer look at the syntax. When we write `var AllSkills = React.createClass( /* Code here */ )` we give it an object containing all the code for the component. Since elements in objects are comma separated, we put a comma at the end of our functions.

Did you see the output from the `console.log()` in the browser console? Cool! Let's see if we can fetch all skills.

```
$.getJSON('/api/v1/skills.json', (response) => { console.log(response) });
```

Make sure to look in the browser console to make sure everything looks good.

Right now we are just logging the result to make sure we get the objects we want. Really, what we want to do is to store it on the component so we can use it more easily throughout our application. Data that will change is stored as `state` on the component. In React, state is mutable, so data that will change throughout the program should be stored as state. `getInitialState` is another method we get from React and it's used to  specify the initial values for all the states in the component. Let's create a state called `skills` and set it equal to an empty array.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
```
var AllSkills = React.createClass({
  getInitialState() {
    return { skills: [] }
  },

// rest of the component

```

<br>

Now, when we get the response back from the server, we want to update `skills` and set it to the value of the skills we got from the server. We want to store it as state becasue when we add new skills, we want to be able to render them on the page without having to ping the index action of our API again. By using another of React's built in methods, this isn't bad at all.

<br>

```
  $.getJSON('/api/v1/skills.json', (response) => { this.setState({ skills: response }) });
```

<br>

To be sure that we actually updated the state, let's log the state (`console.log(this.state)`) in the `render()` method. Make sure to put it outside of the return statement! You should see something like the following in your browser console.

`this.state.skills` is how we would access the skills array.

<br>

```
> Object {skills: Array[0]}
> Object {skills: Array[50]}
```

<br>

We might eventually want to create a `Skill` component for each object in the skills array. For now, let's just map over the objects in the array and create DOM nodes out of them. Since JSX is just HTML + JS, we can build HTML elements and insert JavaScript wherever we need it, similar to how we can insert Ruby in HTML elements using erb.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
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

<br>

The return value from the `this.state.skills.map...` will be an array of HTML divs, each with an `h3` and two `p` tags (if you don't believe me, log the return value and look). As you can see, inserted JavaScript needs to be enclosed in curly braces - the erb equivalent to this would be `<%= %>`. In the return statement we have replaced the `h1` tag with the skills array we built above. In the return statement we write JSX and our skills array is JavaScript, so in order for it to be evaluated it needs to be wrapped in curly braces. Head over to the browser and make sure it all works ok!

You should see an error like this in the browser console:

<br>

```
Each child in an array or iterator should have a unique "key" prop. Check the render method of `AllSkills`. See https://fb.me/react-warning-keys for more information.
```

<br>

A key prop?

When we are rendering multiple similar HTML elements - in our case, 50 of the same type - we need to supply each with a unique key. React uses a diffing algorithm to figure out which parts of your application has changed and needs to be re-rendered. This is partially what makes React so fast and snappy in the browser. It uses the keys to identify the DOM nodes and if we have several on the same kind, the diffing algorithm doesn't work as it should. For more details on this topic, check out the [docs](https://facebook.github.io/react/docs/reconciliation.html).

Let's help React out and add a key prop.

<br>

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

<br>

The second argument in a map iteration is the index, so let's use it and add unique key props for all the skills we render. Refresh, and voila - no more errors.

<br>

### 7. Add a new skill
---

Remember the `NewSkill` component?

**app/assets/javascripts/components/_new_skill.js.jsx**
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

<br>

What do we need to create a new skill? We need a form where the user can enter a name and details and a submit button which will take the input from the form and send it over to the API and add the skill to the database. Let's start with the form. We are just going to use regular HTML to get the form and the submit button on the page. We add the refs to input fields to be able to fetch their value using `this.refs.name.value && this.refs.details.value`. More info on [refs](https://facebook.github.io/react/docs/more-about-refs.html).

<br>

**app/assets/javascripts/components/_new_skill.js.jsx**
```
return (
  <div>
    <input ref='name' placeholder='Enter name of skill' />
    <input ref='details' placeholder='Details' />
    <button>Submit</button>
  </div>
)
```

<br>

Cool cool cool - but what happens when the user has entered a new skill and hits submit? Nothing. Let's add an event listener.

<br>

```
<button onClick={this.handleClick}>Submit</button>
```

<br>

`onClick` is a React event listener, take a look at the [docs](https://facebook.github.io/react/docs/events.html) to learn more about React events. We give the event listener some JavaScript code to evaluate whenever we click the button. Here, we are telling it to go execute the `handleClick` function - which we haven't written yet.

<br>

```
// var NewSkill = ...

handleClick() {
  console.log('in handle click!')
},

// render()....

```

<br>

Check in the browser if it works and... great! Now, we need to fetch the form values and send it over to the server to create a new skill. Let's log the form values to be sure we have access to them.

<br>

```
let name    = this.refs.name.value;
let details = this.refs.details.value;
console.log(name, details);
```

<br>

Let's send the form values over to the server so we can create a new skill.

<br>

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

<br>

We are making a POST request to '/api/v1/skills' and if it's successful we log the response. Did it work? Create a new skill in the browser and check the browser console. Refresh the page to make sure your newly created skill is rendered on the page.

But we don't want to refresh the page to see our new skills. We can do better.

We store all the skills we get from the server as state in `AllSkills`. When we add a new skill, we could add it to the skills array so it will get rendered immediately with the other skills. `AllSkills` needs to have access to the skills array and `NewSkill` wants to update that array. Both children of `Body` need access to the skills array so we should store it as state in `Body` and give both children access to it.

Let's move some code around. Move `getInitialState()` and `componentDidMount()` from `AllSkills` to `Body`. Now, we fetch the skills when `Body` is mounted on the DOM and we store them as state on the `Body` component.

How does `AllSkills` get access to all the skills?

Parents can send variables down its children as `props`. `Props` are immutable in the child. Let's send the skills array from the `Body` component to the `AllSkills` component as props.

<br>

**app/assets/javascripts/components/_body.js.jsx**
```
<AllSkills skills={this.state.skills} />
```

<br>

We have one more change to do before the skills will render on the DOM. In `AllSkills` we are iterating over `this.state.skills` to create DOM elements but we no longer have that state stored on the component. `AllSkills` receives the skills as props from the parent, so instead of `this.state.skills` we need to ask for `this.props.skills`.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
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

<br>

Like we can pass down values from parents to children, we can also pass function references that can be executed in the child.

Let's starts from the `Body`. We want to build a function that's called `handleSubmit()` that will add the new skill to the skills array.

<br>

**app/assets/javascripts/components/_body.js.jsx**
```
// getInitialState() and componentDidMount()

handleSubmit(skill) {
  console.log(skill);
},

// renders the AllSkills and NewSkill component

```

<br>

Then, we want to send a reference to this function down to the `NewSkill` component.

<br>

```
<NewSkill handleSubmit={this.handleSubmit} />
```

<br>

In the `NewSkill` component, we can call this function by adding parenthesis, just like a regular JavaScript function. In the `success` function, execute the `handleSubmit` function and give it the name and details as an object as an argument.

<br>

**app/assets/javascripts/components/_new_skill.js.jsx**
```
$.ajax({
  url: '/api/v1/skills',
  type: 'POST',
  data: { skill: { name: name, details: details } },
  success: (skill) => {
    this.props.handleSubmit(skill);
  }
});
```

<br>

Check your browser console to see if you get any output from `handleSubmit` in the `Body` component.

Almost there!

Now we need to add it to `this.state.skills`. We can use `concat()` to add the skill to the old state and then set the state with the new state.

<br>

**app/assets/javascripts/components/_body.js.jsx**
```
handleSubmit(skill) {
  let newState = this.state.skills.concat(skill);
  this.setState({ skills: newState })
},
```

<br>

That's it! We have successfully added a new skill that is rendered on the DOM immediately.

Here is the code for `Body`, `AllSkills` and `NewSkill` in case you want to check your code.

<br>

**app/assets/javascripts/components/_body.js.jsx**
```
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

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
```
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

<br>

**app/assets/javascripts/components/_new_skill.js.jsx**
```
var NewSkill = React.createClass({
  handleClick() {
    let name    = this.refs.name.value;
    let details = this.refs.details.value;

    $.ajax({
      url: '/api/v1/skills',
      type: 'POST',
      data: { skill: { name: name, details: details } },
      success: (skill) => {
        this.props.handleSubmit(skill);
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

<br>

### 8. Delete a skill
---

Ok, we can render skills and add new ones. Let's implement deleting skills so we can get rid of all the test skills we have added.

What do we need to do?

1. Add a delete button to each skill
2. Create a click event for the delete button that will travel up to `Body`
3. Remove the the skill from the skills array
4. Update the state in `Body` with the new skills array
5. Make an Ajax call to our server to remove it from the database

Let's start with adding a delete button to each skill with an on click listener that takes us to the function `handleDelete` in the same component.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
```
var AllSkills = React.createClass({
  handleDelete() {
    console.log('in delete skill');
  },

  render() {
    let skills = this.props.skills.map((skill, index) => {
      return (
        <div key={index}>
          <h3>{skill.name}</h3>
          <p><strong>Level:</strong> {skill.level}</p>
          <p>{skill.details}</p>
          <button onClick={this.handleDelete}>Delete</button>
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
<br>

Does it log to the browser console? Cool, we are good to go. Earlier I said that we were going to add a `Skill` component for each skill, but we aren't feeling any obvious pains from this setup, so let's keep it like it is.

The component needs to communicate with the parent and tell it to delete the idea that was clicked. Like we passed down a function reference to `NewSkill`, we are going to pass down a function reference that the child can execute when we click the `delete` button.

<br>


**app/assets/javascripts/components/_body.js.jsx**
```
// getInitialState() and componentDidMount()

handleDelete() {
  console.log('in handle delete');
},

// render <NewSkill />

<AllSkills skills={this.state.skills} handleDelete={this.handleDelete} />
```

<br>

Great! Now, we need to execute the function in the child when we hit the `handleDelete()`.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
```
var AllSkills = React.createClass({
  handleDelete() {
    this.props.handleDelete();
  },

// render() ...

```

<br>

We have one pretty obvious problem to solve before we continue. How does the program know *which* skill it is that we want to delete? In the `Body` component we need to use some data that identifies the skill we want to remove so we can filter it out from the skills array. How about an id?

If we use the skill id and pass it as an argument to `this.props.handleDelete()` we can easily filter the correct skill out by filtering out the skill with a matching id.

Let's use our dear friend `bind()` - the first argument in `bind()` is the value to be passed as the `this` value when the function is executed and consecutive arguments will be passed to the bound function as arguments.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
```
handleDelete(id) {
  this.props.handleDelete(id);
},

// iterate over the skills and create HTML elements

 <button onClick={this.handleDelete.bind(this, skill.id)}>Delete</button>

// render() etc

```

<br>

Now, in `handleDelete()` in the `Body` component we need to use the id passed up from the `AllSkills` component and remove the skill from the database using an Ajax call.

<br>

**app/assets/javascripts/components/_body.js.jsx**
```
handleDelete(id) {
  $.ajax({
    url: `/api/v1/skills/${id}`,
    type: 'DELETE',
    success(response) {
      console.log('successfully removed skill', response)
    }
  });
},
```

<br>

Click `delete` and check in the console if it worked - you are awesome!

But... unless we refresh the page, the skill is still there. We aren't communicating to our view that the skill should be deleted.

Let's add a callback in the `success()` function that removes the skill from the DOM.

<br>

**app/assets/javascripts/components/_body.js.jsx**
```
handleDelete(id) {
  $.ajax({
    url: `/api/v1/skills/${id}`,
    type: 'DELETE',
    success: () => {
      this.removeIdeaFromDOM(id);
    }
  });
},

removeIdeaFromDOM(id) {
  let newSkills = this.state.skills.filter((skill) => {
    return skill.id != id;
  });

  this.setState({ skills: newSkills });
},
```

<br>

Hop over to the browser and remove some skills... this is fantastic.

<br>

### 9. Edit a skill

The last and final crud functionality. We are rendering all skills on the page, we are creating new ones, we are deleting them and now we just need to be able to edit them.


This is what we need to accomplish:

1. Add an `Edit` button
2. Add a click listener for the `Edit` button
3. On click `Edit`, transform the text fields to input fields (alternatively render a new form below)
4. When the user clicks the `Submit` button, grab the values from the input fields
5. Send the updated values over to our Rails API to update the skill
6. Update the skill and replace the old values with the new values

Let's start with `1` and `2`. Add an `Edit` button and add a click listener for it which takes us to a `handleEdit` function in the same component.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
```
// handleDelete()

handleEdit() {
  console.log('you are in edit!');
},

// render() and rest of the skill template

<button onClick={this.handleEdit}>Edit</button>
```

<br>

Do you get feedback in your browser console when we click `Edit`? Cool.

What needs to happen in `handleEdit()`? For the specific skill that the user asked to edit, add an edit form and let the user edit the values and then submit. If we were using jQuery, we could have just used jQuery's `$.append()` function. However, as this StackOverflow succintly puts it, it's not a [React way](http://stackoverflow.com/questions/31823801/how-to-append-and-prepend-element-in-react-js-like-jquery). We should render components conditionally based on our state and props.

So if each skill needs to know whether or not its `Edit` button has been clicked (information which we should store as state), this seems like a good time to refactor out our current skill template in `AllSkills` to its own component.

<br>

```
$ touch app/assets/javascripts/components/_skill.js.jsx
```

<br>

We need to update `AllSkills` and create `Skill` components when we iterate over the `this.props.skills`. Notice that we need to send the skill, and references to `handleDelete()` and `handleEdit()` as props to `Skill`. This way we can access these values in `Skill` using the `this.props.*` notation.

<br>

**app/assets/javascripts/components/_all_skills.js.jsx**
```
let skills = this.props.skills.map((skill, index) => {
  return (
    <div key={index}>
      <Skill skill={skill}
             handleDelete={this.handleDelete.bind(this, skill.id)}
             handleEdit={this.handleEdit}/>
    </div>
  )
});
```

<br>

In `Skill` we just return the entire template we removed from `AllSkills`. Notice how we changed the JSX to comply with our new setup.

<br>

**app/assets/javascripts/components/_skill.js.jsx**
```
var Skill = React.createClass({
  render() {
    return (
      <div>
        <h3>{this.props.skill.name}</h3>
        <p><strong>Level:</strong> {this.props.skill.level}</p>
        <p>{this.props.skill.details}</p>

        <button onClick={this.props.handleDelete}>
          Delete
        </button>

        <button onClick={this.props.handleEdit}>Edit</button>
      </div>
    )
  }
});
```

<br>

Just to double check that we have wired things up correctly, go to the browser and make sure you can still delete skills and that something logs to the console when you click `Edit`.

Now, when we click `Edit`, we want to set a state that will tell us that we are editing the skill. Change the click listener for the `Edit` button so we land in a handler function in the current component,

<br>

```
<button onClick={this.handleEdit}>Edit</button>
```

<br>

and add that function in the `Skill` component.

<br>

```
handleEdit() {
  // something should happen here
},

```

<br>

Now what? Add an initial state to the `Skill` component that defaults to `false`. In `handleEdit()` we need to set this state to true.

<br>

**app/assets/javascripts/components/_skill.js.jsx**
```
var Skill = React.createClass({
  getInitialState() {
    return { editable: false }
  },

  handleEdit() {
    this.setState({ editable: true })
  },


  // render() etc..
```

<br>

And now what? We need to render the component conditionally based on our state. If `this.state.editable` is false, we want to render `h3` tag with the name and the `p` tag with the details as normal. If not, we want to render and input field for the name and a textarea for the details. Sounds like we need ternary operator.

<br>

**app/assets/javascripts/components/_skill.js.jsx**
```
// getInitialState() and handleEdit()...

render() {
  var name = this.state.editable ? <input type='text' defaultValue={this.props.skill.name} />
                                 : <h3>{this.props.skill.name}</h3>

  let details = this.state.editable ? <textarea type='text' defaultValue={this.props.skill.details}></textarea>
                                    : <p>{this.props.skill.details}</p>
  return (
    <div>
      {name}

      <p><strong>Level:</strong> {this.props.skill.level}</p>
      {details}

      <button onClick={this.props.handleDelete}>
        Delete
      </button>

      <button onClick={this.handleEdit}>Edit</button>
    </div>
  )
}
});
```

<br>

In the render function we are using a ternary to decide how we should render name/details. It doesn't matter what data we give our component, based on its state, props and the constraints we set up, we always know what the component will render. We want dumb child components that just render conditionally based on the props they receive and their current state. Head over to the browser and check it out!

Let's transform the `Edit` button to a `Submit` button when we click `Edit`. We can use the `editable` state and a ternary directly in the JSX to change that.

<br>

**app/assets/javascripts/components/_skill.js.jsx**
```
<button onClick={this.handleEdit}>{this.state.editable ? 'Submit' : 'Edit' }</button>
```

<br>

Awesome.

We can make a small change to how we update the state in `handleEdit()` to make it toggle between true/false.

<br>

```
handleEdit() {
  this.setState({ editable: !this.state.editable })
},
```

<br>

But now, when we click `Submit`, we need to fetch the updated values and send them over to the server to update the given skill. We can do this using component `refs`, same way we got the values from the input fields when we created new skills. Let's add the refs to the input field and the textarea in `Skill` (forgot to carry those over when we extracted the skill to its own component).

<br>

```
var name = this.state.editable ? <input type='text'
                                        ref='name'
                                        defaultValue={this.props.skill.name} />
                               : <h3>{this.props.skill.name}</h3>

let details = this.state.editable ? <textarea type='text'
                                              ref='notes'
                                              defaultValue={this.props.skill.details}>
                                    </textarea>
                                  : <p>{this.props.skill.details}</p>
```

<br>

There are no strict rules on how you choose to format ternaries. The most important thing is to make it readable for future you and other developers.

Let's add some code to `handleEdit()`.

<br>

```
if (this.state.editable) {
  let name    = this.refs.name.value;
  let details = this.refs.details.value;
  console.log('in handleEdit', this.state.editable, name, details);
}

this.setState({ editable: !this.state.editable })
```

<br>

What are we trying to find out here? When we hit this function and `this.state.editable` is true, meaning if we are currently editing the text, we want to grab the name and the details and log them to the browser console. Then, we simply toggle the state to alternate between true/false. Try it out in the browser and make sure it's behaving as expected.

Cool. Let's walk up the chain, from `Skill` to `AllSkills` to `Body` and update the specific skill in the `Body` component. Why update the skill in the `Body` component and not  right away in the `Skill` component? Because we store all skills as state in the `Body` component and data should be updated in one place.

Fetch the values, compose a skill object and trigger the chain by executing the `handleUpdate()` function reference passed down by the parent.

<br>

**app/assets/javascripts/components/_skill.js.jsx**
```
onUpdate() {
  if (this.state.editable) {
    let name    = this.refs.name.value;
    let details = this.refs.details.value;
    let skill = { name: name, details: details }

    this.props.handleUpdate(skill);
  }
  this.setState({ editable: !this.state.editable })
},
```

<br>

This component is just passing it up to its parent.

<br>


**app/assets/javascripts/components/_all_skills.js.jsx**
```
onUpdate(skill) {
  this.props.onUpdate(skill);
},

render() {
  let skills = this.props.skills.map((skill, index) => {
    return (
      <div key={index}>
        <Skill skill={skill}
               handleDelete={this.handleDelete.bind(this, skill.id)}
               handleUpdate={this.onUpdate}/>
      </div>
    )
  });
```

<br>

This is the end of the chain and where we use the `skill` object passed up to update the state, `this.state.skills`.

<br>

**app/assets/javascripts/components/_body.js.jsx**
```
handleUpdate(skill) {
  console.log(skill, 'in handleUpdate');
},

render() {
  return (
    <div>
      <NewSkill handleSubmit={this.handleSubmit} />
      <AllSkills skills={this.state.skills}
                 handleDelete={this.handleDelete}
                 onUpdate={this.handleUpdate} />
    </div>
  )
}
```

<br>

Since `this.state.skills` is an array of objects it makes most sense to just swap out entire objects instead of opening one up and updating single properties on that object. Let's update the object we pass up from `Skill` to look more like the objects we store as state in `Body`.

<br>

```
let id      = this.props.skill.id;
let name    = this.refs.name.value;
let details = this.refs.details.value;
let level   = this.props.skill.level;

let skill = {id: id, name: name, details: details, level: level }
```

<br>

In `handleUpdate()` in the `Body` component we need to swap out the old object with the new one - and make an Ajax call to update the database.

<br>

```
handleUpdate(skill) {
  $.ajax({
    url: `/api/v1/skills/${skill.id}`,
    type: 'PUT',
    data: { skill: skill },
    success: () => {
      console.log('you did it');
      this.updateSkills(skill);
      // callback to swap objects
    }
  });
},
```

<br>

And now let's write the callback that will swap out the objects.

<br>

```
handleUpdate(skill) {
    // ajax stuffs
    success: () => {
      this.updateSkills(skill)
    }
  });
},

updateSkills(skill) {
  let skills = this.state.skills.filter((s) => { return s.id != skill.id });
  skills.push(skill);

  this.setState({ skills: skills });
},
```

<br>

First we filter out the skill that matches `skill.id`, then we are pushing the updated skill onto the filtered skills array and then we are updating the state with the correct values.

<br>

### 10. Updating the level of a skill
---

Last thing we will do before we see if there are any opportunities to refactor our code is updating the level of a skill. Either we could have three buttons corresponding to each of the levels (bad, half-bad and fantastic), or, we could have an up arrow and a down arrow and when the user clicks either it levels up and down respectively.

It seems like implementing the arrows will take slightly more work, so let's do that.

First, we need our arrow buttons - and we'll be adding our first css!

<br>
```
$ touch app/assets/stylesheets/skills.scss
```

<br>

**app/assets/stylesheets/application.scss**
```
@import "skills";
```

<br>

**app/assets/stylesheets/skills.scss**
```
.skill-level {
  display: inline-flex;
}

.skill-level button {
  background-color: pink;
  border: 1px solid deeppink;
}
```

<br>

Wrap the `level` with the arrow buttons.

<br>

**app/assets/components/javascripts/_skill.js.jsx**
```
<div className='skill-level'>
  <button type="button" className="btn btn-default btn-sm">
    <span className="glyphicon glyphicon-triangle-bottom"></span>
  </button>

    <p><strong>Level:</strong> {this.props.skill.level}</p>

  <button type="button" className="btn btn-default btn-sm">
    <span className="glyphicon glyphicon-triangle-top"></span>
  </button>
</div>
```

<br>

Let's write down a todo-list for this feature.

1. Add click events to the arrows - bind an argument to the function so we know which button was clicked
2. In the click handler, check if it's possible to decrease/increase the level (is it already the lowest/highest value?)
3. Depending on #2, send a request to the server to update the status

For #3 we can use the same chain we used for editing the name and the details (`this.props.handleUpdate()`).

Let's add a click listener for both arrow buttons and bind arguments to them.

<br>

**app/assets/components/javascripts/_skill.js.jsx**
```
<div className='skill-level'>
  <button type="button"
          className="btn btn-default btn-sm"
          onClick={this.handleLevelChange.bind(this, 'down')}>
    <span className="glyphicon glyphicon-triangle-bottom"></span>
  </button>

    <p><strong>Level:</strong> {this.props.skill.level}</p>

  <button type="button"
          className="btn btn-default btn-sm"
          onClick={this.handleLevelChange.bind(this, 'up')}>
    <span className="glyphicon glyphicon-triangle-top"></span>
  </button>
</div>

```

<br>

Now we need logic in `handleLevelChange()` to decide whether or not to update the level when we click either button.

<br>

**app/assets/components/javascripts/_skill.js.jsx**
```
handleLevelChange(action) {
  let levels  = ['bad', 'halfbad', 'fantastic'];
  let name    = this.props.skill.name;
  let details = this.props.skill.details;
  let level   = this.props.skill.level;
  let index   = levels.indexOf(level);

  if (action === 'up' && index < 2) {
    let newLevel = levels[index + 1];
    this.props.handleUpdate({id: this.props.skill.id, name: name, details: details, level: newLevel})
  } else if (action === 'down' && index > 0) {
    let newLevel = levels[index - 1];
    this.props.handleUpdate({id: this.props.skill.id, name: name, details: details, level: newLevel})
  }
},

```

<br>

That code is working. It's not pretty, but it's working.

I'm going to keep it like this and deal with it first thing in next section - time to refactor!

<br>

### 11. Refactor
---

To refactor the code above, it's a good start to try to state what is happening in the function.

'If the level can be changed, send the updated object up the chain to be updated'.

That gave me this:

<br>

**app/assets/components/javascripts/_skill.js.jsx**
```
handleLevelChange(action) {
  if (this.levelCanBeChanged(action)) {
    let skill = this.updatedSkill()
    this.props.handleUpdate(skill);
  }
},

```

<br>

`this.levelCanBeChanged(action)` will return either true or false. We send it the action, either 'up' or 'down', and checks the given limit meets a condition.

**app/assets/components/javascripts/_skill.js.jsx**
```
handleLevelChange(action) {
  let levels  = ['bad', 'halfbad', 'fantastic'];
  let level   = levels.indexOf(this.props.skill.level);

  if (this.levelCanBeChanged(action, level)) {
    let skill = this.updatedSkill()
    this.props.handleUpdate(skill);
  }
},

levlelCanBeChanged(action, limit) {
  return action === 'up' && limit < 2 ||  action === 'down' && limit > 0;
},
```

<br>

Next up is `updatedSkill()`. We return an object with an updated level that is set by checking the action and moving either up or down in an array.

<br>

**app/assets/components/javascripts/_skill.js.jsx**
```
updatedSkill(action, index) {
  let id       = this.props.skill.id;
  let name     = this.props.skill.name;
  let details  = this.props.skill.details;

  let levels   = ['bad', 'halfbad', 'fantastic'];
  let change   = action === 'up' ? 1 : - 1;
  let newLevel = action ? levels[index + change] : this.props.skill.level;

  return {id: id, name: name, details: details, level: newLevel}
},
```

<br>

We can also refactor out the part where we set the new level to a function.

<br>

**app/assets/components/javascripts/_skill.js.jsx**
```
getNewLevel(action, index) {
  let levels   = ['bad', 'halfbad', 'fantastic'];
  let change   = action === 'up' ? 1 : - 1;

  return action ? levels[index + change] : this.props.skill.level;
},
```

<br>

This looks better, but there is more to do in this component. `onUpdate()` can be made better. Let's make it a bit more readable.

<br>

**app/assets/components/javascripts/_skill.js.jsx**
```
onUpdate() {
  if (this.state.editable) {
    let skill   = { id: this.props.skill.id,
                    name: this.refs.name.value,
                    details: this.refs.details.value,
                    level: this.props.skill.level }

    this.props.handleUpdate(skill);
  }

  this.setState({ editable: !this.state.editable })
},
```

<br>

The handler function for the level change, `onLevelChange`, can be renamed to `onUpdateLevel` to better match the naming pattern we have for the editing handler function. To make the following code working below I had to update the implemenation of `this.props.handleUpdate`, `handleUpdate()` in the `Body` component. In this function we are now only passing up the attributes we need to update (we need the id for the Ajax call). We can therefore also drop the `level` attribute in the skill object in `onUpdate()`.

<br>

**app/assets/components/javascripts/_skill.js.jsx**
```
onUpdateLevel(action) {
  if (this.canChangeLevel(action)) {
    let level = this.getNewLevel(action)
    let skill = {id: this.props.skill.id, level: level }

    this.props.handleUpdate(skill);
  }
},
```

<br>

Since we are no longer passing up a full skill object we can no longer use it to update the skill in `updateSkills()`. Instead, we need our API to pass the updated object back so we can keep replacing the old skill with the new skill in `updateSkills`. Otherwise we would have to update only the attributes that were present in the skill object which feels... a bit strange. Also, it's way safer to use the updated object from our API and if we can, we wouldn't we?

<br>

**app/assets/javascripts/components/_body.js.jsx**
```
handleUpdate(skill) {
  $.ajax({
    url: `/api/v1/skills/${skill.id}`,
    type: 'PUT',
    data: { skill: skill },
    success: (skill) => {
      this.updateSkills(skill)
    }
  });
},

```

<br>


**app/skills/controllers/api/v1/skills_controller.rb**
```
def update
  skill = Skill.find(params["id"])
  skill.update_attributes(skill_params)
  respond_with skill, json: skill
end
```

<br>

### 12. You are awesome
---
![](http://reactiongifs.us/wp-content/uploads/2013/02/youre_awesome_carl_sagan.gif)

Possible extensions:

- extract out API calls to service
- add styling (use `className` instead of `class` when adding CSS classes)
- filter skills by level (3 click events on 3 buttons which hides non matching skills)
- filter skills by text (use `onChange` event handler)
- tag skills (personal, professional, urgent)
- create groups of skills


If you are interested in adding sections to this tutorial or find areas for improvement/correction/clarification, please submit a pull request.
