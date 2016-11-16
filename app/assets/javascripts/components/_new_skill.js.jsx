var NewSkill = React.createClass({
  render() {
    return (
      <div>
        <input ref='name' placeholder='Enter name of skill' />
        <input ref='details' placeholder='Details' />
        <button>Submit</button>
      </div>
    )
  }
});
