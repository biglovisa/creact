# Creact
## Crud + React

In this tutorial we are going to create a Rails API and a React front end to build
out basic CRUD functionality.

If you see anything that could be improved upon or should be corrected, please submit a PR!


### 0. up and running

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
- [Thinking in React](https://facebook.github.io/react/docs/thinking-in-react.html)
- [Video](http://tagtree.tv/thinking-in-react) tutorial that walks through the code used in above article


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
  success: (skill) => {
    this.props.handleSubmit(skill);
  }
});

```

Check your browser console to see if you get any output from `handleSubmit` in the `Body` component.

Almost there!

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


### 7. Deleting a skill

Ok, we can render skills and add new ones. Let's implement deleting skills so we can get rid of all the test skills we added.

What do we need to do?

1. Add a delete button to each skill
2. Create a click event for the delete button that will travel up to `Body`
3. Remove the the skill from the skills array
4. Update the state with the new array
5. AND make an Ajax call to our server to remove it from the database

Let's start with adding a delete button to each skill with an on click listener that takes us to the function `handleDelete` in the same component.

```

app/assets/javascripts/components/_all_skills.js.jsx

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

Does it log to the browser console? Cool, we are good to go. Earlier I said that we were going to add a `Skill` component for each skill, but we aren't feeling any obvious pains from this setup, so let's keep it like it is.

The component needs to communicate with the parent and tell it to delete the idea that was clicked. Like we passed down a function reference to `NewSkill`, we are going to pass down a function reference that the child can execute when we click the button `delete`.


```
app/assets/javascripts/components/_body.js.jsx

// getInitialState() and componentDidMount()


handleDelete() {
  console.log('in handle delete');
},

// render <NewSkill />

<AllSkills skills={this.state.skills} handleDelete={this.handleDelete} />

```  

Great! Now, we need to execute the function in the child when we hit the `handleDelete()`.


```

app/assets/javascripts/components/_all_skills.js.jsx

var AllSkills = React.createClass({
  handleDelete() {
    this.props.handleDelete();
  },

// render() ...

```

We have one pretty obvious problem to solve before we continue. How does the program know *which* skill it is that we want to delete? In the `Body` component we need to use some data that identifies the skill we want to remove so we can filter it out from the skills array. How about an id?!

If we use the skill id and pass it as an argument to `this.props.handleDelete()` we can easily filter the correct skill out by filtering out the skill with a matching id.

 Let's use our dear friend `bind()` - the first argument is the value to be passed as the `this` value when the function is executed and consecutive arguments will be passed to the bound function as arguments.


```
app/assets/javascripts/components/_all_skills.js.jsx

handleDelete(id) {
  this.props.handleDelete(id);
},

// iterate over the skills and create HTML elements

 <button onClick={this.handleDelete.bind(this, skill.id)}>Delete</button>

// render() etc

```

Now, in `handleDelete()` in the `Body` component we need to use the id passed up from the `AllSkills` component and remove the skill from the database using an ajax call.


```
app/assets/javascripts/components/_body.js.jsx


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

Click `delete` and check in the console if it worked - you are awesome!

But... unless we refresh the page, the skill is still there. We aren't communicating to our view that the skill should be deleted.

Let's add a callback in the `success()` function that removes the skill from the DOM.


```
app/assets/javascripts/components/_body.js.jsx

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

Hop over to the browser and remove some skills... this is fantastic.

### 8. Editing an idea

The last and final crud functionality. We are rendering all skills on the page, we are creating new ones, we are deleting them and now we just need to be able to edit them.

I just spent 15ish minutes researching HTML5's `contenteditable` tag (just learned about it this week and thought it would be cool to implement). Some StackOverflow's and blog posts said that it was a terrible to use with React. So we won't be using it in this tutorial. If you want to give it a go, please submit a PR with your solution (just append it to the end of this README).

Instead, this is what we need to accomplish:

1. Add an `Edit` button
2. Add a click listener for the `Edit` button
3. On click `Edit`, transform the text fields to input fields (alternatively render a new form below)
4. When the user clicks the `Submit` button, grab the values from the input fields
5. Send the updated values over to our Rails API to update the skill
6. Update the skill and replace the old values with the new values   


Let's start with `1` and `2`. Add an `Edit` button and add a click listener for it which takes us to a `handleEdit` function in the same component.

```
app/assets/javascripts/components/_all_skills.js.jsx

// handleDelete()

handleEdit() {
  console.log('you are in edit!');
},

// render() and rest of the skill template

<button onClick={this.handleEdit}>Edit</button>

```

Do you get feedback in your browser console when we click `Edit`? Cool.

What needs to happen in `handleEdit()`? For the specific skill that the user asked to edit, add an edit form and let the user edit the values and then submit. If we were using jQuery, we could have just used jQuery's `$.append()` function. However, as this StackOverflow succintly puts it, it's not a [React way](http://stackoverflow.com/questions/31823801/how-to-append-and-prepend-element-in-react-js-like-jquery). We should render components conditionally based on our state and props.

So if each skill needs to know whether or not its `Edit` button has been clicked (information which we should store as state), this seems like a good time to refactor out our current skill template in `AllSkills` to its own component.


```
$ touch app/assets/javascripts/components/_skill.js.jsx
```  

Here's how we iterate over the `this.props.skills` to create new skills. Notice that we need to send the skill, and references to `handleDelete()` and `handleEdit()` as props to `Skill`. This way we can access these values in `Skill` using the `this.props.*` notation.

```
app/assets/javascripts/components/_all_skills.js.jsx

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


In `Skill` we just return the entire template we removed from `AllSkills`. Notice how we changed the JSX to comply with our new setup.


```
app/assets/javascripts/components/_skill.js.jsx

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

Just to double check that we have wired things up correctly, go to the browser and make sure you can still delete skill and that it logs to the console when you click `Edit`.


Now, when we click `Edit`, we want to set a state that will tell us that we are editing the skill. Change the click listener for the `Edit` button so we land in a function in the current component,


```
<button onClick={this.handleEdit}>Edit</button>
```

and add that function in the `Skill` component.


```

handleEdit() {
  // something should happen here
},

```

Now what? Add an initial state to the `Skill` component that defaults to `false`. In `handleEdit()` we need to set this state to true.


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


And now what? We need to render the component conditionally based on our state. If `this.state.editable` is false, we want to render `h3` tag with the name and the `p` tag with the details as normal. If not, we want to render and input field for the name and a textarea for the details. Sounds like we need ternary operator.


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


In the render function we are using a ternary operator to decide how we should render name/details. This is the React way. It doesn't matter what data we give our component, based on its state, props and the constraints we set up, we always know what the component will render. Head over to the browser and check it out! (The UI/UX is terrible because we don't have any CSS, feel free to customize it to your heart's content.)

Let's transform the `Edit` button to a `Submit` button when we click `Edit`. We can use the `editable` state and a ternary directly in the JSX to change that.


```
<button onClick={this.handleEdit}>{this.state.editable ? 'Submit' : 'Edit' }</button>
```

Awesome.

We can make a small change to how we update the state in `handleEdit()` to make it toggle between true/false.


```
handleEdit() {
  this.setState({ editable: !this.state.editable })
},
```

Even more awesome.

But now, when we click `Submit`, we want to grab the updated values and send them over to the server to update the given skill. We can do this using component `refs`, same way we got the values from the input fields when we created new skills. Let's add the refs to the input field and the textarea in `Skill` (I forgot to carry those over when we extracted the skill to its own component).


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


There are no strict rules on how you choose to format ternaries (as far as I'm concerned). The most important thing is to make it readable for future you and other developers.

Let's add some code to `handleEdit()`.


```
if (this.state.editable) {
  let name    = this.refs.name.value;
  let details = this.refs.details.value;
  console.log('in handleEdit', this.state.editable, name, details);
}

this.setState({ editable: !this.state.editable })
```

What are we trying to find out here? When we hit this function and `this.state.editable` is true, meaning if we are currently editing the text, we want to grab the name and the details and log them to the browser console. Then, we simply toggle the state. If it's true, toggle to false and if false, toggle to true. Try it out in the browser and make sure it's behaving as expected.       

Cool. Let's walk up the chain, from `Skill` to `AllSkills` to `Body` and update the specific skill in the `Body` component. Why there and not in the `Skill` component right away? Because we store all skills as state in the `Body` component and data should be updated in one place.

Full disclosure: I first tried to make the Ajax call and update the skill in the `Skill` component. The Ajax was no problem but when I tried to update the skill with the new values it felt wrong. It was not an obvious way to do this and updating an individual skill here and not the entire collection violates the principle of maintaining a Single Source of Truth (we would have two represenations of the same skill on the DOM at the same time).

Fetch the values, compose a skill object and trigger the chain by executing the `handleUpdate()` function reference passed down by the parent.

```
app/assets/javascripts/components/_skill.js.jsx

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

This component is just passing it up to its parent.

```
app/assets/javascripts/components/_all_skills.js.jsx

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

This is the end of the chain and where we use the `skill` object passed up to update the state, `this.state.skills`.

```
app/assets/javascripts/components/_body.js.jsx


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


Since `this.state.skills` is an array of objects it makes most sense to just swap out entire objects instead of opening one up and updating single properties on that object. Let's update the object we pass up from `Skill` to look more like the objects we store as state in `Body`.


```
let id      = this.props.skill.id;
let name    = this.refs.name.value;
let details = this.refs.details.value;
let level   = this.props.skill.level;

let skill = {id: id, name: name, details: details, level: level }
```  


In `handleUpdate()` in the `Body` component we need to swap out the old object with the new one - and make an Ajax call to update the database.


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

And now let's write the callback that will swap out the objects.


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

First we filter out the skill that matches `skill.id` and then we are pushing the updated skill onto the filtered skills array and then we are updating the state with the correct values.

That wasn't too bad, right?  

### 9. Updating the level of a skill


Last thing we will do before we see if there are any opportunities to refactor our code is updating the level of a skill. Either we could have three buttons corresponding to each of the levels (bad, half-bad and fantastic), or, we could have an up arrow and a down arrow and when the user clicks either it levels up and down respectively.    

It seems like implementing the arrows will take slightly more work, so let's do that.

First, we need our arrow buttons - and we'll be adding our first css!


```
$ touch app/assets/stylesheets/skills.scss
```

```
app/assets/stylesheets/application.scss

@import "skills";
```

```
app/assets/stylesheets/skills.scss

.skill-level {
  display: inline-flex;
}

.skill-level button {
  background-color: pink;
  border: 1px solid deeppink;
}
```


Wrap the `level` with the arrow buttons.

```
app/assets/components/javascripts/_skill.js.jsx

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


Let's write down a todo-list for this feature.

1. Add click events to the arrows - bind an argument to the function so we know which button was clicked
2. In the click handler, check if it's possible to decrease/increase the level (is it already the lowest/highest value?)
3. Depending on #2, send a request to the server to update the status

For #3 we can use the same chain we used for editing the name and the details (`this.props.handleUpdate()`).

Let's add a click listener for both arrow buttons and bind arguments to them.

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


Now we need some logic in `handleLevelChange()` to decide whether or not to update the level when we click either button.


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

That code was working. It wasn't pretty, but it was working.

I'm going to keep it like this and deal with it first thing in next section - time to refactor!


### 10. Refactor

To refactor this, it's a good start to try to state what is happening in the function.

'If the level can be changed, send the updated object to '


- extract out API calls to service
- create idea object

### 11. Your turn

Possible extensions:

- add styling (use `className` instead of `class` when adding CSS classes)
- filter skills by level (3 click events on 3 buttons which hides non matching skills)
- filter skills by text (use `onChange` event handler)
- tag skills (personal, professional, urgent)
- create groups of skills


If you are interested in adding sections to this tutorial or find areas for improvement/correction/clarification, please submit a PR!
